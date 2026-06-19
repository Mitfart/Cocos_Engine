import { _decorator, CCString, Component, Label, tween, CCFloat, CCInteger, CCBoolean } from 'cc';
import { Score } from './Score';
const { ccclass, property, requireComponent } = _decorator;

@ccclass('UI_ScoreView')
@requireComponent(Label)
export class UI_ScoreLabel extends Component {
    @property(CCBoolean) bonusView: boolean = false;
    @property(CCString) prefix: string = '';
    @property(CCString) postfix: string = '€';
    @property(CCFloat) animDuration: number = .5;
    @property(CCInteger) extraDigitsRound: number = 0;

    private _label: Label = null;
    private animScore: { value: number } = null;


    protected onLoad(): void {
        this._label = this.node.getComponent(Label);

        if (this.bonusView) {
            Score.Events.on(Score.EventType.BONUS_CHANGED, this.set, this);
        } else {
            Score.Events.on(Score.EventType.SCORE_CHANGED, this.set, this);
        }
        
    }

    protected start(): void {
        if (this.bonusView) {
            this.animScore = { value: Score.getBonus() };
            this.set(0, Score.getBonus());
        } else {
            this.animScore = { value: Score.get() };
            this.set(0, Score.get());
        }
    }

    
    private set(curScore: number, newScore: number): void {
        tween(this.animScore)
            .to(this.animDuration, { value: newScore }, {
                onUpdate: ( target: { value: number }) => {
                    if (this._label) 
                        this._label.string = this.getStringFor(target.value);
                }
            })
            .start();
    }

    private getStringFor(score: number) {
        return `${this.prefix}${score.toFixed(this.extraDigitsRound)}${this.postfix}`;
    }
}