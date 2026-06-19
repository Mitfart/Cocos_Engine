import { _decorator, Button, Component } from 'cc';
import super_html_playable from './super_html_playable';
const { ccclass, requireComponent } = _decorator;


@ccclass('UI_GameDownloadBtn')
@requireComponent(Button)
export class UI_GameDownloadBtn extends Component 
{
    private _btn: Button = null;
    
    protected onLoad(): void {
        this._btn = this.getComponent(Button);
        this._btn.node.on(Button.EventType.CLICK, () => { super_html_playable.download(); }, this);
    }
}


