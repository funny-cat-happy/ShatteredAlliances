local inserts = {
    -- vs label
    {
        "hud.lua",
        { "widgets", "mainframePnl", "children" },
        {
            name = [[VSChar]],
            isVisible = true,
            noInput = false,
            anchor = 7,
            rotation = 0,
            x = 1300,
            xpx = true,
            y = 80,
            ypx = true,
            w = 600,
            wpx = true,
            h = 300,
            hpx = true,
            sx = 1,
            sy = 1,
            ctor = [[label]],
            halign = MOAITextBox.LEFT_JUSTIFY,
            valign = MOAITextBox.LEFT_JUSTIFY,
            text_style = [[font1_sb_80px]],
            color =
            {
                0.549019634723663,
                1,
                1,
                1,
            },
        },
    },
    --incognita avatar
    { "hud.lua",
        { "widgets", "mainframePnl", "children" },
        {
            name = [[incognitaInfo]],
            isVisible = true,
            noInput = true,
            anchor = 7,
            rotation = 0,
            x = 700,
            xpx = true,
            y = 130,
            ypx = true,
            w = 0,
            h = 0,
            sx = 1,
            sy = 1,
            ctor = [[group]],
            children =
            {
                {
                    name = [[bg 2]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = 22,
                    xpx = true,
                    y = 44,
                    ypx = true,
                    w = 257,
                    wpx = true,
                    h = 256,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    skin_properties =
                    {
                        position =
                        {
                            default =
                            {
                                x = 22,
                                xpx = true,
                                y = 44,
                                ypx = true,
                            },
                            Small =
                            {
                                x = 21,
                                xpx = true,
                                y = 41,
                                ypx = true,
                            },
                        },
                        size =
                        {
                            default =
                            {
                                w = 257,
                                wpx = true,
                                h = 256,
                                hpx = true,
                            },
                            Small =
                            {
                                w = 208,
                                wpx = true,
                                h = 208,
                                hpx = true,
                            },
                        },
                    },
                    ctor = [[image]],
                    color =
                    {
                        1,
                        1,
                        1,
                        1,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/hud3_char_bg.png]],
                            name = [[]],
                        },
                    },
                },
                {
                    name = [[bg]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = 18,
                    xpx = true,
                    y = 25,
                    ypx = true,
                    w = 168,
                    wpx = true,
                    h = 168,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    skin_properties =
                    {
                        size =
                        {
                            default =
                            {
                                w = 168,
                                wpx = true,
                                h = 168,
                                hpx = true,
                            },
                            Small =
                            {
                                w = 136,
                                wpx = true,
                                h = 136,
                                hpx = true,
                            },
                        },
                    },
                    ctor = [[image]],
                    color =
                    {
                        0.219607844948769,
                        0.376470595598221,
                        0.376470595598221,
                        0.196078434586525,
                    },
                    images =
                    {
                        {
                            file = [[white.png]],
                            name = [[]],
                            color =
                            {
                                0.7843137383461,
                                0,
                                0,
                                0.196078434586525,
                            },
                        },
                    },
                },
                {
                    name = [[incognitaName]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = 57,
                    xpx = true,
                    y = 129,
                    ypx = true,
                    w = 250,
                    wpx = true,
                    h = 26,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    skin_properties =
                    {
                        position =
                        {
                            default =
                            {
                                x = 57,
                                xpx = true,
                                y = 129,
                                ypx = true,
                            },
                            Small =
                            {
                                x = 74,
                                xpx = true,
                                y = 107,
                                ypx = true,
                            },
                        },
                    },
                    ctor = [[label]],
                    halign = MOAITextBox.LEFT_JUSTIFY,
                    valign = MOAITextBox.LEFT_JUSTIFY,
                    text_style = [[font1_16_m]],
                    color =
                    {
                        0.549019634723663,
                        1,
                        1,
                        1,
                    },
                },
                {
                    name = [[incognitaProfileAnim]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = 18,
                    xpx = true,
                    y = 25,
                    ypx = true,
                    w = 168,
                    wpx = true,
                    h = 168,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    scissor =
                    {
                        -250,
                        -250,
                        250,
                        250,
                    },
                    skin_properties =
                    {
                        size =
                        {
                            default =
                            {
                                w = 168,
                                wpx = true,
                                h = 168,
                                hpx = true,
                            },
                            Small =
                            {
                                w = 136,
                                wpx = true,
                                h = 136,
                                hpx = true,
                            },
                        },
                    },
                    ctor = [[anim]],
                    animfile = [[portraits/incognita_face_red]],
                    symbol = [[character]],
                    anim = [[idle]],
                    color =
                    {
                        1,
                        1,
                        1,
                        1,
                    },
                },
                {
                    name = [[static]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = 18,
                    xpx = true,
                    y = 25,
                    ypx = true,
                    w = 168,
                    wpx = true,
                    h = 168,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    skin_properties =
                    {
                        size =
                        {
                            default =
                            {
                                w = 168,
                                wpx = true,
                                h = 168,
                                hpx = true,
                            },
                            Small =
                            {
                                w = 136,
                                wpx = true,
                                h = 136,
                                hpx = true,
                            },
                        },
                    },
                    ctor = [[anim]],
                    animfile = [[gui/hud_portrait_bg_effect]],
                    symbol = [[effect]],
                    anim = [[idle]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.470588237047195,
                    },
                },
            },
        },
    },
    -- incognita program
    {
        "hud.lua",
        { "widgets", "mainframePnl", "children" },
        {
            name = [[incognitaProgramsPanel]],
            isVisible = true,
            noInput = false,
            anchor = 5,
            rotation = 0,
            x = 700,
            xpx = true,
            y = 92,
            ypx = true,
            w = 0,
            h = 0,
            sx = 1,
            sy = 1,
            ctor = [[group]],
            children =
            {
                {
                    name = [[program1]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -46,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[program2]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -103,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[program3]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -159,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[program4]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -216,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[program5]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -273,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[program6]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -330,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[program7]],
                    isVisible = true,
                    noInput = false,
                    anchor = 1,
                    rotation = 0,
                    x = -80,
                    xpx = true,
                    y = -387,
                    ypx = true,
                    w = 0,
                    h = 0,
                    sx = 1,
                    sy = 1,
                    skin = [[ProgramItem]],
                },
                {
                    name = [[empty1]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -21,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
                {
                    name = [[empty2]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -78,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
                {
                    name = [[empty3]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -134,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
                {
                    name = [[empty4]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -191,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
                {
                    name = [[empty5]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -248,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
                {
                    name = [[empty6]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -305,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
                {
                    name = [[empty7]],
                    isVisible = true,
                    noInput = true,
                    anchor = 1,
                    rotation = 0,
                    x = -27,
                    xpx = true,
                    y = -362,
                    ypx = true,
                    w = 256,
                    wpx = true,
                    h = 64,
                    hpx = true,
                    sx = 1,
                    sy = 1,
                    ctor = [[image]],
                    color =
                    {
                        0.317647069692612,
                        0.545098066329956,
                        0.549019634723663,
                        0.800000011920929,
                    },
                    images =
                    {
                        {
                            file = [[gui/hud3/MainframeIcons_agent_program_empty.png]],
                            name = [[]],
                            color =
                            {
                                0.317647069692612,
                                0.545098066329956,
                                0.549019634723663,
                                0.800000011920929,
                            },
                        },
                    },
                },
            },
        } },
    -- alarm disc
    {
        "hud.lua",
        { "widgets", "alarm", "children" },
        {
            name = [[alarmDisc]],
            isVisible = true,
            noInput = false,
            anchor = 1,
            rotation = 0,
            x = -1,
            xpx = true,
            y = -6,
            ypx = true,
            w = 150,
            wpx = true,
            h = 150,
            hpx = true,
            sx = 1,
            sy = 1,
            ctor = [[radialprogressbar]],
            color =
            {
                1,
                0,
                0,
                1,
            },
            images =
            {
                {
                    file = [[alarm_disc.png]],
                    name = [[]],
                },
            },
        },
    }
}
return inserts
