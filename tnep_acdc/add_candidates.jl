function add_converter_candidate!(grid_data, ac_bus_idx, dc_bus_idx, power_rating, inv_cost; zone = nothing, islcc = 0, conv_id = nothing, status = 1)
    if isnothing(conv_id)
        conv_idx = maximum([conv["index"] for (c, conv) in grid_data["convdc"]]) + 1
    else
        conv_idx = conv_id
    end
    grid_data["convdc_cand"]["$conv_idx"] = Dict{String, Any}()  # create dictionary for each converter
    grid_data["convdc_cand"]["$conv_idx"]["busdc_i"] = dc_bus_idx  # assign dc bus idx
    grid_data["convdc_cand"]["$conv_idx"]["busac_i"] = ac_bus_idx  # assign ac bus idx
    grid_data["convdc_cand"]["$conv_idx"]["type_dc"] = 1  # 1 -> const. dc power, 2-> constant dc voltage, 3 -> dc slack for grid. Not relevant for OPF!
    grid_data["convdc_cand"]["$conv_idx"]["type_ac"] = 1  # 1 -> PQ, 2-> PV. Not relevant for OPF!
    grid_data["convdc_cand"]["$conv_idx"]["P_g"] = 0 # converter P set point input
    grid_data["convdc_cand"]["$conv_idx"]["Q_g"] = 0 # converter Q set point input
    grid_data["convdc_cand"]["$conv_idx"]["islcc"] = islcc # LCC converter or not?
    grid_data["convdc_cand"]["$conv_idx"]["Vtar"] = 1 # Target voltage for droop converter, not relevant for OPF!
    grid_data["convdc_cand"]["$conv_idx"]["rtf"] = 0.01 # Transformer resistance in p.u.
    grid_data["convdc_cand"]["$conv_idx"]["xtf"] = 0.01 # Transformer reactance in p.u.
    grid_data["convdc_cand"]["$conv_idx"]["transformer"] = 1 # Binary indicator if transformer is installed
    grid_data["convdc_cand"]["$conv_idx"]["tm"] = 1 # Transformer tap ratio
    grid_data["convdc_cand"]["$conv_idx"]["bf"] = 0.01 # Filter susceptance in p.u.
    grid_data["convdc_cand"]["$conv_idx"]["filter"] = 1 # Binary indicator if transformer is installed
    grid_data["convdc_cand"]["$conv_idx"]["rc"] = 0.01 # Reactor resistance in p.u.
    grid_data["convdc_cand"]["$conv_idx"]["xc"] = 0.01 # Reactor reactance in p.u.
    grid_data["convdc_cand"]["$conv_idx"]["reactor"] = 1 # Binary indicator if reactor is installed
    grid_data["convdc_cand"]["$conv_idx"]["basekVac"] = grid_data["bus"]["1"]["base_kv"]
    grid_data["convdc_cand"]["$conv_idx"]["Vmmax"] = 1.1 # Range for AC voltage
    grid_data["convdc_cand"]["$conv_idx"]["Vmmin"] = 0.9 # Range for AC voltage
    grid_data["convdc_cand"]["$conv_idx"]["Imax"] = power_rating  # maximum AC current of converter
    grid_data["convdc_cand"]["$conv_idx"]["LossA"] = 0 #power_rating * 0.001  # Aux. losses parameter in MW
    grid_data["convdc_cand"]["$conv_idx"]["LossB"] = 0 #0.6 / power_rating # 0.887  # Proportional losses losses parameter in MW
    grid_data["convdc_cand"]["$conv_idx"]["LossCrec"] = 0#2.885  # Quadratic losses losses parameter in MW^2
    grid_data["convdc_cand"]["$conv_idx"]["LossCinv"] = 0#2.885  # Quadratic losses losses parameter in MW^2
    grid_data["convdc_cand"]["$conv_idx"]["droop"] = 0  # Power voltage droop, not relevant for OPF
    grid_data["convdc_cand"]["$conv_idx"]["Pdcset"] = 0  # DC power setpoint for droop, not relevant OPF
    grid_data["convdc_cand"]["$conv_idx"]["Vdcset"] = 0  # DC voltage setpoint for droop, not relevant OPF
    grid_data["convdc_cand"]["$conv_idx"]["Pacmax"] =  power_rating   # maximum AC power
    grid_data["convdc_cand"]["$conv_idx"]["Pacmin"] = -power_rating  # maximum AC power
    grid_data["convdc_cand"]["$conv_idx"]["Pacrated"] =  power_rating    # maximum AC power
    grid_data["convdc_cand"]["$conv_idx"]["Qacrated"] =  0.33 * power_rating  # maximum AC reactive power -> assumption
    grid_data["convdc_cand"]["$conv_idx"]["Qacmax"] =  0.33 * power_rating  # maximum AC reactive power -> assumption
    grid_data["convdc_cand"]["$conv_idx"]["Qacmin"] =  -0.33 * power_rating  # maximum AC reactive power -> assumption
    grid_data["convdc_cand"]["$conv_idx"]["index"] = conv_idx
    grid_data["convdc_cand"]["$conv_idx"]["status"] = status
    grid_data["convdc_cand"]["$conv_idx"]["inertia_constants"] = 10 # typical virtual inertia constant.
    grid_data["convdc_cand"]["$conv_idx"]["source_id"] = []
    grid_data["convdc_cand"]["$conv_idx"]["inv_cost"] = inv_cost
    
    push!(grid_data["convdc_cand"]["$conv_idx"]["source_id"],"convdc_cand")
    push!(grid_data["convdc_cand"]["$conv_idx"]["source_id"],conv_idx)

    if !isnothing(zone)
        grid_data["convdc_cand"]["$conv_idx"]["zone"] = zone
    end

    return conv_idx
end


function add_dc_branch_cand!(grid_data, fbus_dc, tbus_dc, power_rating, inv_cost; status = 1, r = 0.1, branch_id = nothing)
    if isnothing(branch_id)
        dc_br_idx = maximum([branch["index"] for (br, branch) in grid_data["branchdc_cand"]]) + 1
    else
        dc_br_idx = branch_id
    end
    grid_data["branchdc_cand"]["$dc_br_idx"] = Dict{String, Any}()
    grid_data["branchdc_cand"]["$dc_br_idx"]["fbusdc"] = fbus_dc
    grid_data["branchdc_cand"]["$dc_br_idx"]["tbusdc"] = tbus_dc
    grid_data["branchdc_cand"]["$dc_br_idx"]["r"] = r
    grid_data["branchdc_cand"]["$dc_br_idx"]["l"] = 0   # zero in steady state
    grid_data["branchdc_cand"]["$dc_br_idx"]["c"] = 0 # zero in steady state
    grid_data["branchdc_cand"]["$dc_br_idx"]["rateA"] = power_rating
    grid_data["branchdc_cand"]["$dc_br_idx"]["rateB"] = power_rating
    grid_data["branchdc_cand"]["$dc_br_idx"]["rateC"] = power_rating
    grid_data["branchdc_cand"]["$dc_br_idx"]["status"] = status
    grid_data["branchdc_cand"]["$dc_br_idx"]["index"] = dc_br_idx
    grid_data["branchdc_cand"]["$dc_br_idx"]["source_id"] = []
    grid_data["branchdc_cand"]["$dc_br_idx"]["inv_cost"] = inv_cost

    push!(grid_data["branchdc_cand"]["$dc_br_idx"]["source_id"],"branchdc_cand")
    push!(grid_data["branchdc_cand"]["$dc_br_idx"]["source_id"],dc_br_idx)

    return dc_br_idx
end


# adding VOLL generators
function add_VOLL_generators!(data)
    number_of_gen = maximum(parse.(Int, keys(data["gen"])))
    for (b_id,b) in data["bus"]
    number_of_gen += 1
    data["gen"]["$number_of_gen"] = deepcopy(data["gen"]["1"])
    data["gen"]["$gen_idx"]["gen_bus"] = gen_bus
    data["gen"]["$gen_idx"]["source_id"][2] = number_of_gen
    data["gen"]["$gen_idx"]["index"] = gen_idx
    data["gen"]["$gen_idx"]["cost"][1] = 10^5
    data["gen"]["$gen_idx"]["pmax"] = 99.0 
    data["gen"]["$gen_idx"]["index"] = 0.0
    end
end