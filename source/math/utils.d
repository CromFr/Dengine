module math.utils;

import std.math;
import base.vect3d;
import gl3n.linalg : mat4;

mat4 RotationMatrix(in Vect3Df rot){
	return RotationMatrix(rot.x, rot.y, rot.z);
}

mat4 RotationMatrix(in float fX, in float fY, in float fZ){

		float cosx = cos( fX );
		float sinx = sin( fX );
		float cosy = cos( fY );
		float siny = sin( fY );
		float cosz = cos( fZ );
		float sinz = sin( fZ );

		float sxsy = sinx*siny;
		float cxsy = cosx*siny;

		return mat4(
			cosy*cosz,				cosy*sinz,				-siny,		0,
			sxsy*cosz-cosx*sinz,	sxsy*sinz+cosx*cosz,	sinx*cosy,	0,
			cxsy*cosz+sinx*sinz,	cxsy*sinz-sinx*cosz,	cosx*cosy,	0,
			0,						0,						0,			1
		);
}