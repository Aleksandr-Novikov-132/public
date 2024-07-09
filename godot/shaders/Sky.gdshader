shader_type canvas_item;

uniform int iterations: hint_range(10, 25, 1) = 17;
uniform float formuparam: hint_range(0.3, 1.0, 0.01) = 0.53;

uniform int volsteps: hint_range(0, 50, 1) = 10;
uniform float stepsize: hint_range(0.0, 0.2, 0.01)  = 0.1;

uniform float zoom: hint_range(0.1, 10.0, 0.1) = 0.800;
uniform float tile: hint_range(0.2, 1.0, 0.01)   = 0.850;
uniform float position_x: hint_range(-100000.0, 100000.0, 0.1)  = 0.000;
uniform float position_y: hint_range(-100000.0, 100000.0, 0.1)  = 0.000;

uniform float brightness: hint_range(0.001, 0.02, 0.0001) = 0.0015;
uniform float darkmatter: hint_range(0.0, 3.0, 0.001) = 0.300;
uniform float distfading: hint_range(0.0, 1.0, 0.0001) = 0.730;
uniform float saturation: hint_range(0.0, 1.0, 0.0001) = 0.850;

uniform vec4 color: source_color;

void fragment()
{
	vec2 uv=UV;
	vec3 dir=vec3(uv*zoom,1.);

	vec3 from = vec3(position_x, position_y, -1.5);
	//volumetric rendering
	float s = 0.1, fade = 1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) {
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.-dm; // dark matter, don't render near
		v+=fade;
		v+=vec3(s, s*s, s*s*s*s)*color.rgb*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	
	COLOR = vec4(v*.001, 1.0);
}