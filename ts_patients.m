function P = ts_patients(sub)

switch sub
    case 'EsPa'
        P.eoi   = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'I'};
    case 'JaHo'
        P.eoi   = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'};
    case 'RhToLa'
        P.eoi   = {'A', 'B', 'C', 'D', 'E', 'F', 'B''', 'C''', 'F'''};
    case 'SaKh'
        P.eoi   = {'MFG', 'AMY', 'HIP', 'PAR', 'P-PAR'};
    case 'XaPe'
        P.eoi   = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

end
