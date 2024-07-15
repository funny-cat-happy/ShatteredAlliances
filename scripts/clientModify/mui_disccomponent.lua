local mui_component = require("mui/widgets/mui_component")
require("class")

local fsh = [[
        varying vec2 uvVarying;
        varying vec4 colorVarying;

        uniform float progress;

        void main() {
            float angle = 0.3 * 4.0 * 3.14;
            float theta = atan(uvVarying.y - 0.5, uvVarying.x - 0.5);
            float dist = distance(uvVarying, vec2(0.5, 0.5));

            if (theta < 0.0) {
                theta += 2.0 * 3.14;
            }

            if (theta < angle && dist > 0.4 && dist < 0.5) {
                gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
            } else {
                discard;
            }
        }
    ]]
local vsh = [[
    varying vec2 uvVarying;
    varying vec4 colorVarying;

    uniform float progress;

    void main() {
        float angle = 0.3 * 2.0 * 3.14;
        float theta = atan(uvVarying.y - 0.5, uvVarying.x - 0.5);

        if (theta < 0.0) {
            theta += 2.0 * 3.14;
        }

        if (theta < angle) {
            gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
        } else {
            discard;
        }
    }
]]
local function shaderInit()
    local shader = MOAIShader.new()
    shader:load(vsh, fsh)
    shader:reserveUniforms(1)
    shader:declareUniform(1, 'progress', MOAIShader.UNIFORM_FLOAT)
    return shader
end



local mui_disccomponent = class(mui_component)

function mui_disccomponent:init(screen, def)
    self._prop = MOAIProp2D.new()
    self._shader = shaderInit()
    self._prop:setShader(self._shader)
    mui_component:init(self._prop, def)
end

return mui_disccomponent
