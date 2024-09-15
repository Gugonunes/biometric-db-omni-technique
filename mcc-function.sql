CREATE OR REPLACE FUNCTION calc_dist_between_two_maps(
vetor_minucias_1 float[][], vetor_minucias_2 float[][])
RETURNS float
LANGUAGE plpython3u
AS $$
    import numpy as np
    import math

    mcc_sigma_s = 28.0/3.0
    mcc_tau_psi = 400.0
    mcc_mu_psi = 0.01

    def sigmoid(v,u,t):
        expo = math.exp(-t * (v-u))
        return 1 / (1+expo)
    
    def Gs(t_sqr):
        return np.exp(-0.5 * t_sqr / (mcc_sigma_s**2)) / 
        (math.tau**0.5 * mcc_sigma_s)

    def Psi(v):
        return 1.0/(1.0 + np.exp(-mcc_tau_psi * (v - mcc_mu_psi)))

    mcc_radius = 70
    mcc_size = 16
    
    g = 2 * mcc_radius / mcc_size
    x = np.arange(mcc_size)*g - (mcc_size/2)*g + g/2
    y = x[..., np.newaxis]
    iy, ix = np.nonzero(x**2 + y**2 <= mcc_radius**2)
    ref_cell_coords = np.column_stack((x[ix], x[iy]))

    xyd = np.array([(x,y,d) for x,y,_,d in vetor_minucias_1])
    d_cos = np.cos(xyd[:,2]).reshape((-1,1,1))
    d_sin = np.sin(xyd[:,2]).reshape((-1,1,1))
    rot = np.block([[d_cos, d_sin], [-d_sin, d_cos]])
    xy = xyd[:,:2]
    cell_coords = np.transpose(rot@ref_cell_coords.T + 
    xy[:,:,np.newaxis],[0,2,1])
    dists = np.sum((cell_coords[:,:,np.newaxis,:] - xy)**2, -1)
    cs = Gs(dists)
    diag_indices = np.arange(cs.shape[0])
    cs[diag_indices,:,diag_indices] = 0
    local_structures = Psi(np.sum(cs, -1))

    # Calculando as distancias
    xyd2 = np.array([(x,y,d) for x,y,_,d in vetor_minucias_2])
    d_cos2, d_sin2 = np.cos(xyd2[:,2]).reshape((-1,1,1)),
    np.sin(xyd2[:,2]).reshape((-1,1,1))
    rot2 = np.block([[d_cos2, d_sin2], [-d_sin2, d_cos2]])
    
    xy2 = xyd2[:,:2]
    cell_coords2 = np.transpose(rot2@ref_cell_coords.T + 
    xy2[:,:,np.newaxis],[0,2,1])
    dists2 = np.sum((cell_coords2[:,:,np.newaxis,:] - xy2)**2, -1)
    
    cs2 = Gs(dists2)
    diag_indices2 = np.arange(cs2.shape[0])
    cs2[diag_indices2,:,diag_indices2] = 0 
    
    local_structures2 = Psi(np.sum(cs2, -1))

    # Calculando as distancias finais
    dists = np.sqrt(np.sum((local_structures[:,np.newaxis,:] -
    local_structures2)**2, -1))
    dists /= (np.sqrt(np.sum(local_structures**2, 1))[:,np.newaxis] +
    np.sqrt(np.sum(local_structures2**2, 1)))

    minNp = 4
    maxNp = 12
    up = 20
    tp = 2/5
    Na = len(vetor_minucias_1)
    Nb = len(vetor_minucias_2)
    num_p = minNp + round(sigmoid(min(Na,Nb), up, tp) * (maxNp-minNp))
    pairs = np.unravel_index(np.argpartition(dists, num_p, None)[:num_p],
    dists.shape)
    score =  np.mean(dists[pairs[0], pairs[1]])

    return score
$$;