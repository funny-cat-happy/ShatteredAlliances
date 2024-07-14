local mui_component = require("mui/widgets/mui_component")
require("class")

local fsh = [[
        varying vec2 uvVarying;
        varying vec4 colorVarying;

        uniform float progress;

        void main() {
            float angle = progress * 4.0 * 3.14;
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



local mui_discprogressbar = class(mui_component)

function mui_discprogressbar:init(def)
    mui_component:init(MOAIProp2D.new(), def)
    self._shader = shaderInit()
    self._prop:setShader(self._shader)
end

function mui_discprogressbar:setProgress(percentage)
    self._shader:setAttr(1, percentage / 100)
end
