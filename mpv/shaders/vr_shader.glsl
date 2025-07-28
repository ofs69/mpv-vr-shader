//!PARAM zoom
//!DESC Apply zoom zo VR
//!TYPE float
0.5

//!PARAM rotationX
//!DESC Rotate the view on the x axis
//!TYPE float
0.5f;

//!PARAM rotationY
//!DESC Rotate the view on the y axis
//!TYPE float
-0.5f;

//!HOOK OUTPUT
//!BIND HOOKED

vec3 rotateXY(vec3 p, vec2 angle) {
	vec2 c = cos(angle), s = sin(angle);
	p = vec3(p.x, c.x*p.y + s.x*p.z, -s.x*p.y + c.x*p.z);
	return vec3(c.y*p.x + s.y*p.z, p.y, -s.y*p.x + c.y*p.z);
}

float map(float value, float min1, float max1, float min2, float max2) {
  	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec4 hook() {
	#define PI 3.1415926535
	#define DEG2RAD 0.01745329251994329576923690768489
	
	float hfovDegrees = 75.0;
	float vfovDegrees = 60.0;

	float aspectRatio = target_size.x / target_size.y;
	float inverse_aspect = 1.f / aspectRatio;
	float hfovRad = hfovDegrees * DEG2RAD;
	float vfovRad = -2.f * atan(tan(hfovRad/2.f)*inverse_aspect);

    vec2 UV = HOOKED_pos;
	vec2 uv = vec2(UV.s - 0.5, UV.t - 0.5);

	//to spherical
	vec3 camDir = normalize(vec3(uv.xy * vec2(tan(0.5 * hfovRad), tan(0.5 * vfovRad)), zoom));
	//camRot is angle vec in rad
	vec3 camRot = vec3( (vec2(rotationX, rotationY) - 0.5) * vec2(2.0 * PI,  PI), 0.);

    //vec2 res = HOOKED_size;
	//rotate
	vec3 rd = normalize(rotateXY(camDir, camRot.yx));
	
	vec2 texCoord = vec2(atan(rd.z, rd.x) + PI, acos(-rd.y)) / vec2(2.0f * PI, PI);
	
	return HOOKED_tex(texCoord); //vec4(uv.xy, 0.0, 1.0);
}
