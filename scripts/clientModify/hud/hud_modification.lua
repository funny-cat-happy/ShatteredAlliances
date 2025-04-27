local modifications = {
    { "hud.lua",
        { "widgets", "homePanel_top", "children", "incognitaFace", "images" },
        {
            [1] =
            {
                file = [[gui/profile_icons/warez_shopCat_mini.png]]
            }
        }
    },
    { "hud.lua",
        { "widgets", "homePanel_top", "children", "incognitaBtn" },
        {
            name = [[incognitaBtn]],
            isVisible = true,
            noInput = false,
            anchor = 1,
            rotation = 0,
            x = -2,
            xpx = true,
            y = 4,
            ypx = true,
            w = 211,
            wpx = true,
            h = 94,
            hpx = true,
            sx = 1,
            sy = 1,
            ctor = [[button]],
            clickSound = [[SpySociety/HUD/menu/click]],
            hoverSound = [[SpySociety/HUD/menu/rollover]],
            hoverScale = 1.1,
            str = [[STR_4010401120]],
            halign = MOAITextBox.LEFT_JUSTIFY,
            valign = MOAITextBox.CENTER_JUSTIFY,
            text_style = [[font3_16]],
            offset =
            {
                x = 15,
                xpx = true,
                y = 3,
                ypx = true,
            },
            color =
            {
                0.549019634723663,
                1,
                1,
                1,
            },
            line_spacing = -0.5,
            images =
            {
                {
                    file = [[gui/hud3/hud3_incognita_button_frame.png]],
                    name = [[inactive]],
                },
                {
                    file = [[gui/hud3/hud3_incognita_button_frame_white.png]],
                    name = [[hover]],
                },
                {
                    file = [[gui/hud3/hud3_incognita_button_frame_white.png]],
                    name = [[active]],
                },
            },
        },
    },
}
return modifications
