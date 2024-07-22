local modifications = {
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
return modifications
