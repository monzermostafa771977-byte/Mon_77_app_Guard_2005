/**
 * Mon_77 app Guard - Core State Machine (V16.2 Engine)
 * الشعار: «حارس... يحمي جهازك، ويصون خصوصيتك، ويعينك على حماية نفسك»
 */

class GuardStateMachine {
    constructor(config = {}) {
        this.config = {
            dailyLimitMinutes: config.dailyLimitMinutes || 30,
            maxDailyGraces: config.maxDailyGraces || 2,
            defaultGraceMinutes: config.defaultGraceMinutes || 10,
            storageKey: 'mon_guard_state_v16',
            historyKey: 'mon_guard_history_v16',
            pinKey: 'mon_guard_pin',
            ...config
        };

        this.STATES = {
            MONITORING: 'MONITORING',
            RESTRICTED: 'RESTRICTED',
            GRACE_PERIOD: 'GRACE'
        };

        this.state = {
            currentState: this.STATES.MONITORING,
            dailyUsageSeconds: 0,
            graceCountToday: 0,
            activeGraceSeconds: 0,
            lastActiveTimestamp: Date.now(),
            lastDateString: new Date().toLocaleDateString('en-CA')
        };

        this.timerInterval = null;
        this.onStateChangeCallback = null;
        this.onTickCallback = null;

        this._init();
    }

    _init() {
        this._loadState();
        this._checkNewDayReset();
        this._startHeartbeat();
    }

    _startHeartbeat() {
        if (this.timerInterval) clearInterval(this.timerInterval);

        this.timerInterval = setInterval(() => {
            const now = Date.now();
            const elapsedSeconds = Math.max(0, Math.floor((now - this.state.lastActiveTimestamp) / 1000));
            this.state.lastActiveTimestamp = now;

            this._checkNewDayReset();

            if (this.state.currentState === this.STATES.MONITORING) {
                this.state.dailyUsageSeconds += elapsedSeconds;
                const limitInSeconds = this.config.dailyLimitMinutes * 60;

                if (this.state.dailyUsageSeconds >= limitInSeconds) {
                    this._transitionTo(this.STATES.RESTRICTED, 'DAILY_LIMIT_REACHED');
                }
            } 
            else if (this.state.currentState === this.STATES.GRACE_PERIOD) {
                this.state.activeGraceSeconds -= elapsedSeconds;
                this.state.dailyUsageSeconds += elapsedSeconds;

                if (this.state.activeGraceSeconds <= 0) {
                    this.state.activeGraceSeconds = 0;
                    this._transitionTo(this.STATES.RESTRICTED, 'GRACE_EXPIRED');
                }
            }

            this._saveState();

            if (typeof this.onTickCallback === 'function') {
                this.onTickCallback(this.getStatusSummary());
            }
        }, 1000);
    }

    requestGracePeriod(requestedMinutes, reason) {
        if (!reason || reason.trim().length < 3) {
            return { success: false, message: '⚠️ يجب ذكر سبب واضح ومكتوب لطلب المهلة.' };
        }

        if (this.state.currentState === this.STATES.GRACE_PERIOD) {
            return { success: false, message: '⚠️ توجد مهلة نشطة بالفعل حالياً.' };
        }

        if (this.state.graceCountToday >= this.config.maxDailyGraces) {
            return { success: false, message: `❌ استنفدت سقف المهلات اليومية المسموح به (${this.config.maxDailyGraces} مهلات).` };
        }

        const graceMinutes = Math.min(requestedMinutes || this.config.defaultGraceMinutes, 15);

        this.state.graceCountToday += 1;
        this.state.activeGraceSeconds = graceMinutes * 60;

        this._logHistoryEvent('GRACE_GRANTED', {
            requestedMinutes: graceMinutes,
            reason: reason.trim(),
            graceIndexToday: this.state.graceCountToday
        });

        this._transitionTo(this.STATES.GRACE_PERIOD, 'USER_REQUESTED_GRACE');
        this._saveState();

        return { 
            success: true, 
            message: `✅ تم منح مهلة إضافية مدتها ${graceMinutes} دقيقة. تبقى لك ${this.config.maxDailyGraces - this.state.graceCountToday} مهلة اليوم.` 
        };
    }

    _checkNewDayReset() {
        const todayStr = new Date().toLocaleDateString('en-CA');
        if (this.state.lastDateString !== todayStr) {
            this._logHistoryEvent('DAILY_SUMMARY', {
                date: this.state.lastDateString,
                totalUsageMinutes: Math.round(this.state.dailyUsageSeconds / 60),
                totalGracesUsed: this.state.graceCountToday
            });

            this.state.dailyUsageSeconds = 0;
            this.state.graceCountToday = 0;
            this.state.activeGraceSeconds = 0;
            this.state.lastDateString = todayStr;
            this.state.currentState = this.STATES.MONITORING;

            this._saveState();
        }
    }

    _transitionTo(newState, reasonCode) {
        const oldState = this.state.currentState;
        this.state.currentState = newState;

        this._logHistoryEvent('STATE_CHANGED', { from: oldState, to: newState, reason: reasonCode });
        this._saveState();

        if (typeof this.onStateChangeCallback === 'function') {
            this.onStateChangeCallback(newState, oldState, reasonCode);
        }
    }

    _logHistoryEvent(eventType, details = {}) {
        try {
            const history = JSON.parse(localStorage.getItem(this.config.historyKey) || '[]');
            history.unshift({
                timestamp: new Date().toISOString(),
                event: eventType,
                ...details
            });
            localStorage.setItem(this.config.historyKey, JSON.stringify(history.slice(0, 100)));
        } catch (e) {
            console.error('Failed to save history log:', e);
        }
    }

    _saveState() {
        try {
            localStorage.setItem(this.config.storageKey, JSON.stringify(this.state));
        } catch (e) {}
    }

    _loadState() {
        try {
            const saved = localStorage.getItem(this.config.storageKey);
            if (saved) {
                this.state = { ...this.state, ...JSON.parse(saved) };
            }
        } catch (e) {}
    }

    getStatusSummary() {
        const limitSec = this.config.dailyLimitMinutes * 60;
        const remainingSec = Math.max(0, limitSec - this.state.dailyUsageSeconds);
        
        return {
            state: this.state.currentState,
            isRestricted: this.state.currentState === this.STATES.RESTRICTED,
            dailyUsageMinutes: Math.floor(this.state.dailyUsageSeconds / 60),
            remainingUsageSeconds: remainingSec,
            activeGraceSeconds: this.state.activeGraceSeconds,
            graceCountToday: this.state.graceCountToday,
            gracesLeftToday: Math.max(0, this.config.maxDailyGraces - this.state.graceCountToday),
            formattedRemaining: this._formatTime(this.state.currentState === this.STATES.GRACE_PERIOD ? this.state.activeGraceSeconds : remainingSec)
        };
    }

    _formatTime(totalSec) {
        const m = Math.floor(totalSec / 60);
        const s = totalSec % 60;
        return `${m < 10 ? '0' : ''}${m}:${s < 10 ? '0' : ''}${s}`;
    }
}
