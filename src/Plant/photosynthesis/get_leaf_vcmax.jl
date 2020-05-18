"""
    get_leaf_vcmax(v25, tem)

Leaf maximal carboxylation rate at leaf temperature, given
- `v25` Maximal carboxylation rate at 298.15 K (25 Celcius)
- `tem` Leaf temperature
"""
function get_leaf_vcmax(v25::FT, tem::FT) where {FT}
    factor = PS_V_C * exp( PS_V_HA / GAS_R / K_25 * (1 - K_25/tem) ) / ( 1 + exp( (PS_V_SV*tem-PS_V_HD) / (GAS_R*tem) ) )
    return v25 * factor
end
