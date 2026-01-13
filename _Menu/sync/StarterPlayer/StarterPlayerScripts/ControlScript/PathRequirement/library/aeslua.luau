local private = {};
local public = {};
aeslua = public;

local ciphermode = require(script.Parent:WaitForChild("ciphermode"));
local util = require(script.Parent:WaitForChild("util"));

--Syntatic sugar
local string_char = string.char
local string_sub = string.sub
local string_byte = string.byte


public.AES128 = 16;
public.AES192 = 24;
public.AES256 = 32;

public.ECBMODE = 1;
public.CBCMODE = 2;
public.OFBMODE = 3;
public.CFBMODE = 4;

function private.pwToKey(password, keyLength)
    local padLength = keyLength;
    if (keyLength == public.AES192) then
        padLength = 32;
    end
    
    if (padLength > #password) then
        local postfix = "";
        for i = 1,padLength - #password do
            postfix = postfix .. string_char(0);
        end
        password = password .. postfix;
    else
        password = string_sub(password, 1, padLength);
    end
    
    local pwBytes = {string_byte(password,1,#password)};
    password = ciphermode.encryptString(pwBytes, password, ciphermode.encryptCBC);
    
    password = string_sub(password, 1, keyLength);
   
    return {string_byte(password,1,#password)};
end

function public.encrypt(password, data, keyLength, mode)
	assert(password ~= nil, "Empty password.");
	assert(password ~= nil, "Empty data.");
	 
    local mode = mode or public.CBCMODE;
    local keyLength = keyLength or public.AES128;

    local key = private.pwToKey(password, keyLength);
	
    local paddedData = util.padByteString(data, key);
	
    if (mode == public.ECBMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptECB);
    elseif (mode == public.CBCMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptCBC);
    elseif (mode == public.OFBMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptOFB);
    elseif (mode == public.CFBMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptCFB);
    else
        return nil;
    end
end


return public