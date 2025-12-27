-- Fuzzy matching with improved output handling and better error management

gg.setRanges(gg.REGION_CODE_APP)
gg.startFuzzy(gg.TYPE_DWORD)
gg.alert('ᴄʟɪᴄᴋ ᴀɢᴀɪɴ ɪғ ʏᴏᴜʀ ᴅᴏɴᴇ')

-- Function to reverse hex bytes (little-endian to big-endian)
function reverseHex(hexValue)
    local hexStr = string.format("%08X", hexValue)
    local reversed = ""
    for i = 7, 1, -2 do
        reversed = reversed .. string.sub(hexStr, i, i+1)
    end
    return reversed
end

-- Function to generate the Setvalue code
function generateSetvalueCode(address, offset, value)
    local reversedHex = reverseHex(value)
    return string.format('so = gg.getRangesList("%s")[1].start\nsetvalue(so + 0x%X, 4, "h%s")', address, offset, reversedHex)
end

-- Function to convert results to offsets
function convertResultsToOffsets(baseAddr, address)
    return address - baseAddr
end

-- Function to find the library for a given address
function findLibraryForAddress(address)
    local ranges = gg.getRangesList("")
    for _, range in ipairs(ranges) do
        if address >= range.start and address <= range["end"] then
            return range
        end
    end
    return nil
end

-- Function to extract library name from file path
function getLibraryName(path)
    local name = path:match(".+/([^/]+)%.so")
    return name or "ᴜɴᴋɴᴏᴡɴ-ʟɪʙ"
end

-- Function to write output to a file
function writeToFile(filePath, output, includeSetValue)
    local file, err = io.open(filePath, "w")
    if file then
        file:write([[
 " Created By DaikieSan "
  
]])
        file:write("\n")
        if includeSetValue then
            file:write("function setvalue(address, flags, value)\n")
            file:write("  local refinevalues = {}\n")
            file:write("  refinevalues[1] = {}\n")
            file:write("  refinevalues[1].address = address\n")
            file:write("  refinevalues[1].flags = flags\n")
            file:write("  refinevalues[1].value = value\n")
            file:write("  gg.setValues(refinevalues)\n")
            file:write("end\n\n")
        end
        file:write(table.concat(output, "\n"))
        file:close()
        gg.alert("ʀᴇsᴜʟᴛs sᴀᴠᴇᴅ ᴛᴏ " .. filePath)
    else
        gg.alert("ᴇʀʀᴏʀ ᴡʀɪᴛɪɴɢ ᴛᴏ ғɪʟᴇ: " .. (err or "unknown error"))
    end
end

-- Function to handle user actions based on the search results
function doAction()
    gg.searchFuzzy("0", gg.SIGN_FUZZY_NOT_EQUAL, gg.TYPE_DWORD)
    local results = gg.getResults(gg.getResultsCount())
    if #results == 0 then
        gg.alert("ɴᴏ ʀᴇsᴜʟᴛs ғᴏᴜɴᴅ.")
        return
    end

    -- User selection for preferred output
    local alertOption = gg.choice({"ᴅɪsᴘʟᴀʏ ғᴜʟʟ ʜᴇxᴘᴀᴛᴄʜᴇs?", "ᴅɪsᴘʟᴀʏ ᴏғғsᴇᴛ ᴏɴʟʏ?", "ᴅɪsᴘʟᴀʏ sᴇᴛᴠᴀʟᴜᴇ ᴄᴏᴅᴇ?"}, nil, "ᴄʜᴏᴏsᴇ ʏᴏᴜʀ ᴘʀᴇғᴇʀʀᴇᴅ ᴏᴜᴛᴘᴜᴛ🤖")
    if alertOption == nil then
        gg.alert("No option selected.")
        return
    end

    local hexPatchOutput = {}
    local offsetOnlyOutput = {}
    local setValueOutputs = {}

    -- Process each result
    for _, result in ipairs(results) do
        local maskedValue = result.value & 0xFFFFFFFF
        local reversedHex = reverseHex(maskedValue)
        local range = findLibraryForAddress(result.address)
        if range then
            local libBaseAddr = range.start
            local detectedLibName = range.internalName and range.internalName:match("([^/]+)%.so") or getLibraryName(range.fileName)
            detectedLibName = detectedLibName .. ".so"
            local offset = convertResultsToOffsets(libBaseAddr, result.address)
            local setvalueCode = generateSetvalueCode(detectedLibName, offset, maskedValue)

            -- Handle based on user-selected output
            if alertOption == 1 then
                table.insert(hexPatchOutput, string.format('HexPatches.Hooked("%s", 0x%X, "h%s", 4);', detectedLibName, offset, reversedHex))
            elseif alertOption == 2 then
                table.insert(offsetOnlyOutput, string.format('%s 0x%X', detectedLibName, offset))
            elseif alertOption == 3 then
                if not setValueOutputs[detectedLibName] then
                    setValueOutputs[detectedLibName] = {}
                end
                table.insert(setValueOutputs[detectedLibName], setvalueCode)
            end
        end
    end

    -- Save outputs to file
    if alertOption == 1 or alertOption == 2 then
        local filePath = "/storage/emulated/0/Dump-Hook.lua"  -- Default file path, could be customized
        writeToFile(filePath, alertOption == 1 and hexPatchOutput or offsetOnlyOutput, false)
    elseif alertOption == 3 then
        for libName, output in pairs(setValueOutputs) do
            local filePath = "/storage/emulated/0/" .. libName .. "-Hook.lua"
            writeToFile(filePath, output, true)
        end
    end
end

-- Set visibility to false and run the action once user clicks
gg.setVisible(false)
while true do
    if gg.isVisible() then
        gg.setVisible(false)
        doAction()
        break
    end
    gg.sleep(1)
end

