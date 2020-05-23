# PLANT MODULE

## Plant Structure

### Root
```@docs
Land.Plant.RootLayer
Land.Plant.create_root_list
Land.Plant.Root
```

### Trunk and Branch
```@docs
Land.Plant.Stem
Land.Plant.create_branch_list
Land.Plant.Branch
```

### Canopy and Leaf
```@docs
Land.Plant.Leaf
Land.Plant.CanopyLayer
Land.Plant.Canopy
```

### Tree
```@docs
Land.Plant.Tree
```

## Plant Hydraulics
```@docs
Land.Plant.get_struct_p_end_from_q
Land.Plant.get_q_layer_from_p_base
Land.Plant.get_p_base_q_list_from_q
Land.Plant.update_struct_from_q!
Land.Plant.update_tree_e_crit!
```

## Stoma Dynamics
```@docs
Land.Plant.get_marginal_gain
Land.Plant.get_marginal_penalty_wang
Land.Plant.update_tree_with_time!
```

## Photosynthesis Tools (migration required)
```@docs
Land.Plant.get_a_par_curve
Land.Plant.get_a_pi_curve
```

## Interfaces
```@docs
Land.Plant.initialize_rt_module
Land.Plant.update_canopy_from_rt_module!
```

## Water Physics (need generalization)
```@docs
Land.Plant.get_relative_surface_tension
Land.Plant.get_relative_viscosity
Land.Plant.get_saturated_vapor_pressure
Land.Plant.get_specific_latent_heat
```