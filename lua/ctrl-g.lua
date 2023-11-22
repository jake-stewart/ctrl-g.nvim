local String = require("String")
local Array = require("Array")
local range = require("range")

local function extendHl(name, extends, opts)
    local hl = vim.api.nvim_get_hl(0, {name = extends})
    local extended = vim.tbl_extend('force', {}, hl, opts)
    vim.api.nvim_set_hl(0, name, extended)
end

local function shrinkHome(string)
    local HOME = vim.fn.expand("$HOME")
    return string
        :replace("^" .. HOME .. "/", "~/")
        :replace("^" .. HOME .. "$", "~")
end

local function commonArrayPrefix(a, b)
    local common = Array()
    for i in range(math.min(#a, #b)) do
        if a:at(i) == b:at(i) then
            common:push(a:at(i))
        else
            break
        end
    end
    return common
end

local function showFile()
    local filePathParts = String(
        vim.fn.fnamemodify(vim.fn.bufname(), ":p")):split("/")
    local cwd = vim.fn.getcwd()
    local cwdPathParts = String(cwd):split("/")
    local commonPathParts = commonArrayPrefix(filePathParts, cwdPathParts)
    local commonPath = commonPathParts:join("/")
    local remainingPath = filePathParts:slice(#commonPathParts):join("/")
    local output = Array({})
    if #commonPath > 0 then
        if commonPath == cwd then
            output:push({shrinkHome(commonPath), "CurrentDirectory"})
        else
            output:push({shrinkHome(commonPath), "Directory"})
        end
        if #remainingPath > 0 then
            output:push({"/", "Directory"})
        end
    else
        output:push({"/", "Directory"})
    end
    if #remainingPath > 0 then
        output:push({remainingPath})
    end
    vim.api.nvim_echo(output, false, {})
end

return {
    setup = function()
        extendHl("CurrentDirectory", "Directory", {underline = true})
        vim.keymap.set("n", "<c-g>", showFile)
    end
}
