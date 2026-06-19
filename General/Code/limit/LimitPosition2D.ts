import { _decorator, CCBoolean, Component, log, math, Vec2, Vec3} from 'cc';
const { ccclass, property } = _decorator;

@ccclass('LimitPosition2D')
export class LimitPosition2D extends Component {
    @property({type: Vec2, visible: true}) private _size: Vec2 = new Vec2;

    @property({type: Vec2, visible: true}) private _minLimits: Vec2 = new Vec2;
    @property({type: Vec2, visible: true}) private _maxLimits: Vec2 = new Vec2;
    @property(CCBoolean) worldSpace: boolean;

    private _halfSize: Vec2 = new Vec2;
    private _trueMinLimits: Vec2 = new Vec2;
    private _trueMaxLimits: Vec2 = new Vec2;

    private _pos: Vec3 = new Vec3();


    protected start(): void {
        this.calcTrueLimits();
    }

    protected lateUpdate(): void {
        if (this.worldSpace) 
            this.node.getWorldPosition(this._pos); 
        else 
            this.node.getPosition(this._pos); 
        

        this._pos.x = math.clamp(this._pos.x, this._trueMinLimits.x, this._trueMaxLimits.x);
        this._pos.y = math.clamp(this._pos.y, this._trueMinLimits.y, this._trueMaxLimits.y);
        
        
        if (this.worldSpace) 
            this.node.setWorldPosition(this._pos); 
        else 
            this.node.setPosition(this._pos); 
    }


    public getSize(): Vec2 { 
        return this._size; 
    }
    
    public setSize(value: Vec2) { 
        this.setSize2f(value.x, value.y);
    }

    public setSize2f(x: number, y: number) { 
        this._size.set(x, y);
        this._halfSize = this._size.clone().divide2f(2, 2);

        this.calcTrueLimits();
    }

    
    public getMinLimits(): Vec2 { 
        return this._minLimits.clone(); 
    }
    
    public setMinLimits(value: Vec2) { 
        this.setMinLimits2f(value.x, value.y);
    }

    public setMinLimits2f(x: number, y: number) { 
        this._minLimits.set(x, y);

        this.calcTrueLimits();
    }
    
    
    public getMaxLimits(): Vec2 { 
        return this._maxLimits.clone(); 
    }
    
    public setMaxLimits(value: Vec2) { 
        this.setMaxLimits2f(value.x, value.y);
    }

    public setMaxLimits2f(x: number, y: number) { 
        this._maxLimits.set(x, y);

        this.calcTrueLimits()
    }


    private calcTrueLimits() {
        this._trueMinLimits.x = this._minLimits.x + this._halfSize.x;
        this._trueMinLimits.y = this._minLimits.y + this._halfSize.y;

        this._trueMaxLimits.x = this._maxLimits.x - this._halfSize.x;
        this._trueMaxLimits.y = this._maxLimits.y - this._halfSize.y;
        
        if (this._trueMinLimits.x > this._trueMaxLimits.x) {
            const mid = (this._trueMinLimits.x + this._trueMaxLimits.x) / 2;
            this._trueMinLimits.x = this._trueMaxLimits.x = mid;
        }

        if (this._trueMinLimits.y > this._trueMaxLimits.y) {
            const mid = (this._trueMinLimits.y + this._trueMaxLimits.y) / 2;
            this._trueMinLimits.y = this._trueMaxLimits.y = mid;
        }
    }
}