password = "b3b25bb14" -- < aici pui parola 


require("addon")
local sampev = require("samp.events")
local dialog_id = 1
function sampev.onShowDialog(id, style, title, btn1, btn2, text)
	print(dialog_id)
    if id == dialog_id then
		
        sendDialogResponse(id, 1, -1, password)
        return false
    end
end



