-- Assigns claspects based on personality, attributes etc.
aspects={
	"BREATH_1", --1
	"LIGHT_1",
	"TIME_1",
	"SPACE_1",
	"LIFE_1",
	"HOPE_1",
	"VOID_1",
	"HEART_1",
	"BLOOD_1",
	"DOOM_1",
	"MIND_1",
	"RAGE_1"}

syndromeUtil=require('syndrome-util')

rng=dfhack.random.new()

function assignClaspect(unit,aspect)
	return dfhack.run('classes/change-class','-unit',unit,'-class',aspect)
end

function unitAlreadyHasClaspect(unit)
    for k,c_syn in ipairs(unit.syndromes.active) do
		for _,ce in ipairs(df.global.world.raws.syndromes.all[c_syn.type].ce) do
			if tostring(ce):find("display_namest") and ce.name:find('player') then return true end
		end
	end
    return false
end

debugScript=false

function creatureIsSburbable(unit)
	for k,class in ipairs(df.creature_raw.find(unit.race).caste[unit.caste].creature_class) do
		if string.find(class.value,"SBURB") then return true end
	end
	return false
end

function unitDoesntNeedClaspect(unit)
	return not creatureIsSburbable(unit) or unitAlreadyHasClaspect(unit)
end

function makeClaspect(unit,unitidx)
	if df.global.gamemode==1 and unitidx==0 then
		local script = require('gui.script')
        script.start(function()
		local lok,aspect_num,aspect=script.showListPrompt('Aspect selection','Which aspect do you want to pick?',COLOR_WHITE,aspects)
        assignClaspect(unit,aspect)
        end)
        return aspect
	end
	local creatureAspect = rng:random(13)+1
	if assignClaspect(unit,claspects.aspects[creatureAspect]) then
		return creatureAspect
	end
	return false
end


dfhack.onStateChange.claspect = function(code)
	local pauseCounter=0
	if code==SC_WORLD_LOADED then
		fortbentInorganic=dfhack.matinfo.find('INORGANIC:FORTBENT_CLASPECTS').material
		dfhack.timeout(1,'ticks',monthlyClaspectAssign)
	end
	if code==SC_PAUSED then
		pauseCounter=pauseCounter+1
		if pauseCounter>=10 then
			assignAllClaspects()
			pauseCounter=0
		end
	end
end

function assignAllClaspects()
	if df.global.gamemode==1 then makeClaspect(df.global.world.units.active[0],0) end
	for k,unit in ipairs(df.global.world.units.active) do
		if not(unitDoesntNeedClaspect(unit)) then 
			makeClaspect(unit,k) 
		end
	end
end

function monthlyClaspectAssign()
	assignAllClaspects()
	dfhack.timeout(1,'months',monthlyClaspectAssign)
end

if ... == "force" then assignAllClaspects() end