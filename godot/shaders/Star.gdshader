shader_type canvas_item;

const float _spot_brightness = 10.0;

uniform vec2 offset = vec2(0.0, 0.0);
uniform float zoom: hint_range(0.1, 2.0, 0.1) = 1.0;
uniform float radius: hint_range(10.0, 1000.0, 0.5) = 100.0;

uniform float intencity: hint_range(0.05, 2.0, 0.05) = 0.5;
uniform float ray_brightness: hint_range(1.0, 20.0, 0.1) = 10.0;
uniform float gamma: hint_range(1.0, 20.0, 0.1) = 8.0;
uniform float ray_density: hint_range(1.0, 20.0, 0.1) = 3.5;
uniform vec3 color: source_color = vec3(1.0, 0.1, 0.1);
uniform float curvature: hint_range(0.1, 1000.0, 0.1) = 15.0;

float hash(float n) {
	return fract(sin(n)*43758.5453);
}

float noise(in vec2 x) {
	x *= 1.75;
	vec2 p = floor(x);
	vec2 f = fract(x);
	
	f = f * f * (3.0 - 2.0 * f);
	float n = p.x + p.y * 57.0;

	float res = mix(mix( hash(n+  0.0), hash(n+  1.0), f.x),
					mix( hash(n+ 57.0), hash(n+ 58.0), f.x), f.y);
	return res;
}

float fbm(in vec2 p) {
	vec2 part1 = vec2(0.80, 0.60);
	vec2 part2 = vec2(-0.60, 0.80);
	mat2 m2 = mat2(part1, part2);
	
	float z = 2.0;
	float rz = 0.0;
	p *= 0.25;
	for (float i= 1.0; i < 6.0; i++)
	{
		rz += abs((noise(p) - 0.5) * 2.0) / z;
		z = z * 2.0;
		p = p * 2.0 * m2;
	}
	return rz;
}

void fragment()
{
	vec2 real_offset = offset * SCREEN_PIXEL_SIZE * zoom;
	vec2 uv = UV - 0.5 + real_offset;
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	uv /= zoom;
	uv *= curvature * 0.05 + 0.0001;
	
	float t = -TIME * intencity;
	float r  = sqrt(dot(uv, uv));
	float x = dot(normalize(uv), vec2(0.5, 0.0)) + t;
	float y = dot(normalize(uv), vec2(0.0, 0.5)) + t;
	
	float val = fbm(vec2(r + y * ray_density, r + x * ray_density - y));
	val = smoothstep(gamma * 0.02 - 0.1, ray_brightness + (gamma * 0.02 - 0.1) + 0.001, val);
	val = sqrt(val);
	
	vec3 col = val / color;
	col = clamp(1.0 - col, 0.0, 1.0);
	col = mix(col, vec3(1.0), _spot_brightness - 200000.0 * r /curvature / radius);
	col = clamp(col, 0.0, 1.0);
	col = pow(col, vec3(1.7));
	
	COLOR = vec4(col, clamp(length(col), 0.0, 1.0));
}