include <../linalg.scad>;

// --- Vector constructors ----------------------------------------------------
echo("vec3([1,2]) =", vec3([1,2]));        // expect [1,2,0]
echo("vec4([1,2,3]) =", vec4([1,2,3]));    // expect [1,2,3,1]
echo("unit([3,0,0]) =", unit([3,0,0]));    // expect [1,0,0]

// --- Identity matrices ------------------------------------------------------
echo("identity3() =", identity3());        // expect 3x3 identity
echo("identity4() =", identity4());        // expect 4x4 identity

// --- Vector access ----------------------------------------------------------
echo("take3([9,8,7,6]) =", take3([9,8,7,6])); // expect [9,8,7]
echo("tail3([0,1,2,3,4,5]) =", tail3([0,1,2,3,4,5])); // expect [3,4,5]

// --- Matrix parts -----------------------------------------------------------
M = [
    [1,0,0,5],
    [0,1,0,6],
    [0,0,1,7],
    [0,0,0,1]
];
echo("rotation_part(M) =", rotation_part(M)); // expect identity3()
echo("translation_part(M) =", translation_part(M)); // expect [5,6,7]

// --- Rotation metrics -------------------------------------------------------
R = identity3();
echo("rot_trace(R) =", rot_trace(R)); // expect 3
echo("rot_cos_angle(R) =", rot_cos_angle(R)); // expect 1

// --- Transpose --------------------------------------------------------------
A3 = [[1,2,3],[4,5,6],[7,8,9]];
echo("transpose_3(A3) =", transpose_3(A3)); // expect [[1,4,7],[2,5,8],[3,6,9]]

A4 = identity4();
echo("transpose_4(identity4) =", transpose_4(A4)); // expect identity4()

// --- Rigid transform inverse/construct -------------------------------------
echo("invert_rt(M) =", invert_rt(M));
// expect transform with R=I, t=[-5,-6,-7]

R2 = [[0,-1,0],[1,0,0],[0,0,1]]; // 90° rot about Z
t2 = [10,0,0];
Rt = construct_Rt(R2,t2);
echo("construct_Rt(R2,t2) =", Rt);

// --- Hadamard product ------------------------------------------------------
echo("hadamard([1,2,3],[4,5,6]) =", hadamard([1,2,3],[4,5,6])); 
// expect [4,10,18]

echo("hadamard([[1,2],[3,4]], [[5,6],[7,8]]) =", 
     hadamard([[1,2],[3,4]], [[5,6],[7,8]])); 
// expect [[5,12],[21,32]]
