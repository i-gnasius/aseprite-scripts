-----------------------------------
-- Slice spritesheet into frames
-----------------------------------

local sourceSprite = app.sprite

if not sourceSprite then
    app.alert("There is no spritesheet to slice")
    return
end

local modeBySize = "Slice sprite by cell size"
local modeByCount = "Slice sprite by cell count"

function UpdateDialog(dialog)
    if dialog.data.mode == modeBySize then
        dialog:modify { id = "header", text = "Slice Size" }
        dialog:modify { id = "width", visible = true, enabled = true }
        dialog:modify { id = "height", visible = true, enabled = true }
        dialog:modify { id = "col", visible = false, enabled = false }
        dialog:modify { id = "row", visible = false, enabled = false }
    elseif dialog.data.mode == modeByCount then
        dialog:modify { id = "header", text = "Slice Count" }
        dialog:modify { id = "col", visible = true, enabled = true }
        dialog:modify { id = "row", visible = true, enabled = true }
        dialog:modify { id = "width", visible = false, enabled = false }
        dialog:modify { id = "height", visible = false, enabled = false }
    end
end

local dialog = Dialog("Slice sprites to frames")

dialog
    :combobox {
        id = "mode",
        label = "Mode",
        option = modeBySize,
        options = { modeBySize, modeByCount },
        onchange = function() UpdateDialog(dialog) end
    }

	-- TODO:
    -- frame_order {left2right, top2bottom}

    :separator { id = "header", text = "Slice Size" }

    :number { id = "width", label = "Width:", text = "10", focus = true }
    :number { id = "height", label = "Height:", text = "10" }

    :number { id = "col", label = "Column:", text = "1", visible = false, enabled = false }
    :number { id = "row", label = "Row:", text = "1", visible = false, enabled = false }

    :check { id = "empty", text = "Include transparent frame", selected = false }

    :button { id = "ok", text = "&OK", focus = true }
    :button { text = "&Cancel" }

    :show()

UpdateDialog(dialog)

if not dialog.data.ok then return end

function Slicer(data, sprite)
    local self = {}
    self.sprite = sprite
    self.includeEmpty = data.empty

    if data.mode == modeBySize then
        self.col = math.floor(sprite.width / data.width)
        self.row = math.floor(sprite.height / data.height)
        self.width = data.width
        self.height = data.height
    elseif data.mode == modeByCount then
        self.col = data.col
        self.row = data.row
        self.width = math.floor(sprite.width / data.col)
        self.height = math.floor(sprite.height / data.row)
    end

    self.slice = function(sprite)
        local image = Image(self.sprite)
        local layer = sprite.layers[1]
        local first = true

        for y = 0, self.row - 1, 1 do
            for x = 0, self.col - 1, 1 do
                local rect = Rectangle(x * self.width, y * self.height, self.width, self.height)
                local slice = Image(image, rect)

                if not slice:isEmpty() or self.includeEmpty then
                    local frame

                    if first then
                        first = false
                        frame = sprite.frames[1]
                    else
                        frame = sprite:newEmptyFrame()
                    end

                    sprite:newCel(layer, frame, slice)
                end
            end
        end
    end

    return self
end

local slicer = Slicer(dialog.data, sourceSprite)
local destinationSprite = Sprite(slicer.width, slicer.height)

slicer.slice(destinationSprite)

