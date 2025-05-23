local len = pandoc.text.len
local sub = pandoc.text.sub

-- True if str starts with prefix
local function hasPrefix(prefix, str)
	local pfxLen = len(prefix)
	local strLen = len(str)
	if pfxLen == strLen then
		return prefix == str
	end
	if pfxLen < strLen then
		return prefix == sub(str, 1, pfxLen)
	end
	return false
end

function Link(link)
	local target = link.target

	-- Check for targets on the same page
	-- TODO: handle ../
	local bareTarget, _ = target:gsub("[#?].*$", "")
	-- strip leading ./
	while hasPrefix("./", bareTarget) do
		bareTarget = sub(bareTarget, 3)
	end
	-- No-op for targets on the same page
	if bareTarget == "" or bareTarget == "." then
		return nil
	end

	-- Relative links should target the github repo
	if not hasPrefix("https://", target) then
		link.target = githubUrl .. target
		return link
	end

	-- Check for absolute links, pointing to the docs website
	if docsUrl == target then
		link.target = "."
		return link
	end
	if hasPrefix(docsUrl, target) then
		local i = len(docsUrl) + 1
		link.target = sub(target, i)
		return link
	end
end
