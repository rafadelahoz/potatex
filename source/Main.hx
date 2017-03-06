package;

import openfl.Assets;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.themes.GradientTheme;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.events.MenuEvent;
import haxe.ui.toolkit.style.StyleManager;
import haxe.ui.toolkit.style.Style;

class Main {
    public static function main() {
        Toolkit.theme = new GradientTheme();

        setupStyles();

        Toolkit.init();
        Toolkit.openFullscreen(function(root:Root) {
            root.addChild(new MainController().view);
       });
    }

    static function setupStyles()
    {
        Macros.addStyleSheet("assets/style.css");
        var f = Assets.getFont("fonts/Arial.ttf");
        // var fb = Assets.getFont("fonts/Oxygen-Bold.ttf");
        StyleManager.instance.addStyle("Text", new Style( {
            fontSize: 14,
            fontName: f.fontName,
            color: 0x444444
        }));

        StyleManager.instance.addStyle("Button.answered", new Style({
            backgroundColor: 0x90BA9F,
        	backgroundColorGradientEnd: 0x70977D,
        	color: 0xFFFFFF,
        	borderColor: 0x496752
        }));

        StyleManager.instance.addStyle("Button.correct", new Style({
            backgroundColor: 0x00FF0a,
        	backgroundColorGradientEnd: 0x00FA05,
        	color: 0xFFFFFF,
        	borderColor: 0x495267
        }));

        StyleManager.instance.addStyle("Button.wrong", new Style({
            backgroundColor: 0xFF000a,
        	backgroundColorGradientEnd: 0xFA0005,
        	color: 0xFFFFFF,
        	borderColor: 0x674952
        }));

        StyleManager.instance.addStyle("Button.unknown", new Style({
            backgroundColor: 0x909090,
        	backgroundColorGradientEnd: 0x707070,
        	color: 0xFFFFFF,
        	borderColor: 0x505050
        }));
    }
}
