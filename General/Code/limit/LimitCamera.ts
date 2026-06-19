import { _decorator, Node, log, screen, UITransform, Vec2, Vec3, view, CCBoolean} from 'cc';
import { LimitPosition2D } from './LimitPosition2D';
import { OrientationSwitch } from '../adaptive/OrientationSwitch';
const { ccclass, property } = _decorator;

@ccclass('LimitCamera')
export class LimitCamera extends OrientationSwitch {
    @property(UITransform) level: UITransform = null;
    
    private _limit: LimitPosition2D = null;


    protected onLoad(): void {
        this._limit = this.node.addComponent(LimitPosition2D);
        this._limit.worldSpace = true;

        super.onLoad();
    }

    protected applyOrientation(isPortrait: boolean): void {
        const v = view.getVisibleSize();
        this._limit.setSize2f(v.width, v.height);
        
        const halfSize = (this.level && this.level.contentSize 
            ? new Vec2(this.level.contentSize.width, this.level.contentSize.height,)
            : new Vec2(v.width, v.height)
        ).multiply2f(
            this.level.node.worldScale.x / 2,
            this.level.node.worldScale.y / 2
        );

        this._limit.setMinLimits2f(
            this.level.node.worldPositionX - halfSize.x,
            this.level.node.worldPositionY - halfSize.y
        );

        this._limit.setMaxLimits2f(
            Math.max(v.width, this.level.node.worldPositionX + halfSize.x), 
            Math.max(v.height, this.level.node.worldPositionY + halfSize.y), 
        );
    }
}