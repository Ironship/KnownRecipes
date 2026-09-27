local ADDON_NAME = ...

-- Which game this is.
--
-- World of Warcraft: Forever answers WOW_PROJECT_ID as if it were Retail, so
-- the Classic file's own test would miss it. On Forever the flag turns on one
-- thing: the warlock grimoire check and the pet spellbook events behind it. The
-- auction house and the guild bank are hooked by addon name, not by this flag.
--
-- The one answer Forever gives that Retail does not is its version: 1.60.x,
-- where Classic Era is 1.15.x. So the major and minor are what decide it, the
-- same rule the QuestWordHunter addons use.
--
-- Loaded before KnownRecipesClassic.lua, which reads the flag as it loads.

local version = GetBuildInfo()
local major, minor = tostring(version or ""):match("^(%d+)%.(%d+)")
major, minor = tonumber(major), tonumber(minor)

KnownRecipesForever = {
	isForever = (major == 1 and minor ~= nil and minor >= 60) or false,
	version = version,
}

SLASH_KRFOREVER1 = "/krforever"
SLASH_KRFOREVER2 = "/krf"
-- Only a key of the game's own table is written. Assigning the global itself
-- ("SlashCmdList = SlashCmdList or {}") tainted it, and the next secure code to
-- read it -- /run and its script prompt -- was blocked and blamed on this addon.
SlashCmdList["KRFOREVER"] = function(msg)
	local function say(text)
		print("|cffffcc00" .. ADDON_NAME .. ":|r " .. text)
	end
	if strtrim(msg or ""):lower() == "pet" then
		if KnownRecipesForever.petReport then
			KnownRecipesForever.petReport(say)
		else
			say("the addon file itself did not load, so there is no pet report")
		end
		return
	end
	local v, build, _, iface = GetBuildInfo()
	say(string.format("client %s (%s), interface %s, WOW_PROJECT_ID=%s",
		tostring(v), tostring(build), tostring(iface), tostring(WOW_PROJECT_ID)))
	say(string.format("recognised as Forever: %s%s", tostring(KnownRecipesForever.isForever),
		KnownRecipesForever.isForever and " -- so the Classic reading of this game is on" or ""))
	say(string.format("collections on this client: PetJournal=%s MountJournal=%s Transmog=%s TooltipInfo=%s",
		tostring(_G.C_PetJournal ~= nil), tostring(_G.C_MountJournal ~= nil),
		tostring(_G.C_TransmogCollection ~= nil), tostring(_G.C_TooltipInfo ~= nil)))
	say(string.format("merchant hook in place: %s -- open a vendor and known items turn colour",
		tostring(type(_G.MerchantFrame_UpdateMerchantInfo) == "function")))
	-- Did the conditional file load? The addon proper registers this command
	-- as it loads, so its absence is the answer.
	say(string.format("the addon file itself loaded: %s  (the toc asks for it with "
		.. "[AllowLoadGameType classic, camelot])",
		tostring(SlashCmdList and SlashCmdList.KNOWNRECIPES ~= nil)))
	say("colours and the rest: /kr")
	say("a warlock's demon and the spells kept for it: /krf pet")
end
