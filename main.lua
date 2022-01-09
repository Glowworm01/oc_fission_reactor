local component = require("component")
local term = require("term")
local nc = component.nc_fission_reactor

-- CONFIG --
local min_energy_cutoff = 10
local max_energy_cutoff = 99
local heat_limit = 50


local calcStartEnergyCutoff = function()
  local current_energy = nc.getEnergyStored()
  if current_energy >= min_energy_cutoff then
    return min_energy_cutoff
  else
    return max_energy_cutoff
  end
end


local displayInfo = function(fuel, effic, store, max_e, e_perc, heat, max_h, heat_m, cells, active)
  term.clear()
  term.setCursor(1,1)
  if active then
  term.write("Reactor is running.\n")
  else
  term.write("Reactor is not running.\n")
  end
  term.write("Current Fuel: "..fuel.."\n")
  term.write("Reactor Efficiency: "..effic.."\n")
  term.write("Stored Energy: "..store.."/"..max_e.." ("..e_perc.."%)\n")
  term.write("Heat Level: "..heat.."/"..max_h.."\n")
  term.write("Heat Multiplier: "..heat_m.."\n")
  term.write("No. Cells: "..cells.."\n")
end


local energy_cutoff = calcStartEnergyCutoff()
while true do
  local max_energy = nc.getMaxEnergyStored()
  local stored_energy = nc.getEnergyStored()
  local energy_perc = (stored_energy/max_energy)*100

  if energy_perc >= energy_cutoff then
      nc.deactivate()
      energy_cutoff = min_energy_cutoff
    else
      nc.activate()
      energy_cutoff = max_energy_cutoff
  end

  local heat_level = nc.getHeatLevel()
  local max_heat = nc.getMaxHeatLevel()
  local heat_multiplier = nc.getHeatMultiplier()
  if heat_level >= heat_limit then
    nc.deactivate()
  end

  local efficiency = nc.getEfficiency()
  local cells = nc.getNumberOfCells()
  local active = nc.isProcessing()
  local fuel_type = nc.getFissionFuelName()

  displayInfo(fuel_type, efficiency, stored_energy, max_energy, energy_perc, heat_level, max_heat, heat_multiplier, cells, active)
end
