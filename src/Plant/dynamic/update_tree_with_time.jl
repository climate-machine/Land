"""
    update_tree_with_time!(tree, Δt; scheme="Wang2020", updating=false)

# Arguments
- `tree::Tree`        Tree struct to operate on
- `Δt::FT`            Δt
- `scheme::String`    Optimization model option, will be updated to abstract type once more models are added
- `updating::Bool`    If true, plant hydraulic parameters will be updated for the Tree struct

# Description
Update the tree fluxes information for a given tree within a given time "Δt".
The function updates the stomatal conductance via a Δgsw = factor * (∂A∂E - ∂Θ∂E).
The ∂A∂E is the same for every stomatal control model, but ∂Θ∂E differs among models.
The default "scheme" for computing ∂Θ∂E is from the Wang 2020 model.
"""
function update_tree_with_time!(tree::Tree, Δt::FT=FT(1.0); scheme::String="Wang2020", updating::Bool=false) where {FT}
    # 0. unpack necessary structs
    @unpack branch_list = tree.branch
    @unpack canopy_list = tree.canopy
    @unpack root_list   = tree.roots

    # 1. use the gsw from last time instant and update e and a first, because Tleaf was from the last instant
    for canopyi in canopy_list
        # 1.1 update the e and a for each leaf, per leaf area
        canopyi.d_list  = (get_saturated_vapor_pressure(canopyi.t_list) .- canopyi.p_H₂O) ./ canopyi.p_atm
        canopyi.e_list  = canopyi.gsw_list .* canopyi.d_list
        canopyi.q_list  = canopyi.e_list   .* canopyi.la_list
        anagrpi_lists   = get_leaf_an_ag_r_pi_from_gsc_list(
                                                            v25 = canopyi.v_max,
                                                            j25 = canopyi.j_max,
                                                         Γ_star = canopyi.Γ_star,
                                                       gsc_list = canopyi.gsc_list,
                                                            p_a = canopyi.p_a,
                                                       tem_list = canopyi.t_list,
                                                       par_list = canopyi.par_list,
                                                          p_atm = canopyi.p_atm,
                                                           p_O₂ = canopyi.p_O₂,
                                                            r25 = canopyi.r_25)
        canopyi.an_list = anagrpi_lists[1]
        canopyi.ag_list = anagrpi_lists[2]
        canopyi.r_list  = anagrpi_lists[3]
        canopyi.pi_list = anagrpi_lists[4]
    end

    # update the pressure profile in the trunk, branch, and lea
    if updating
        # 2. update the pressure profiles for roots
        q_canopy_list      = [sum(canopyi.q_list) for canopyi in canopy_list]
        q_sum              = sum(q_canopy_list)
        p_base,q_root_list = get_p_base_q_list_from_q(tree, q_sum)
        for indx in 1:length(root_list)
            rooti = root_list[indx]
            update_struct_from_q!(rooti, q_root_list[indx])
        end

        # 3. update the pressure profile in the trunk
        tree.trunk.p_ups = p_base
        update_struct_from_q!(tree.trunk, q_sum)

        # 4. update the pressure profiles in the branches and leaves
        for indx in 1:length(branch_list)
            # 4.1 update the pressure profile in the branch
            branchi       = branch_list[indx]
            canopyi       = canopy_list[indx]
            branchi.p_ups = tree.trunk.p_dos
            update_struct_from_q!(branchi, q_canopy_list[indx])
            
            # 4.2 update the pressure profiles for leaves
            for ind_leaf in 1:length(canopyi.leaf_list)
                leaf = canopyi.leaf_list[ind_leaf]
                leaf.p_ups = branchi.p_dos
                update_struct_from_q!(leaf, canopyi.e_list[ind_leaf])
            end
        end
    end

    # 5. determine how much gsw and gsc should change with time, use Wang 2020 model for day time, will add scheme for nighttime later
    for canopyi in canopy_list
        # 5.1 compute the ∂A∂E and ∂Θ∂E for each leaf
        list_∂A∂E = get_marginal_gain(canopyi)
        list_∂Θ∂E = get_marginal_penalty_wang(canopyi)

        # update the gsw and gsc for each leaf
        canopyi.gsw_list += canopyi.gs_nssf .* (list_∂A∂E - list_∂Θ∂E) .* Δt
        canopyi.gsw_list[ canopyi.gsw_list .< 0 ] .= 0
        canopyi.gsc_list  = canopyi.gsw_list ./ FT(1.6) ./ ( 1 .+ canopyi.g_ias_c .* canopyi.gsw_list .^ (canopyi.g_ias_e) )
    end
end