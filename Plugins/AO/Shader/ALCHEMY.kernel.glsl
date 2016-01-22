/**
 * 
 * RenderPipeline
 * 
 * Copyright (c) 2014-2016 tobspr <tobias.springer1@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


/*

ALCHEMY AO

Projects random points to screen space, and uses the average unoccluded vector
to approximate AO.

*/


const float sample_radius = GET_SETTING(AO, alchemy_sample_radius);
const int num_samples = GET_SETTING(AO, alchemy_num_samples) * 4;
float max_dist = GET_SETTING(AO, alchemy_max_distance);
float accum = 0.0;
float accum_count = 0;

vec3 bent_normal = vec3(0);

vec2 offset_scale = pixel_size * sample_radius * kernel_scale * 0.5;

for (int i = 0; i < num_samples; ++i) {

    // Get random texcoord offset
    vec2 offset = poisson_disk_2D_32[i];
    offset = mix(offset, noise_vec.xy, 0.3);

    vec2 offcoord = texcoord + offset * offset_scale;

    // Get view position at that offset
    vec3 off_pos = get_view_pos_at(offcoord);

    // Get the vector s-p to that sample position
    vec3 sample_vec = normalize(off_pos - pixel_view_pos);

    // Check if the distance matches, discard matches which are too far away
    float dist = distance(off_pos, pixel_view_pos) / max_dist;
    if (dist < 1.0) {

        // Weight sample by the angle
        accum += max(0, dot(pixel_view_normal, sample_vec)) * (1-dist);
        // Update bent normal
        bent_normal += normalize(-sample_vec);
    }

    accum_count += 1.0;

}

// Normalize
bent_normal /= max(1.0, length(bent_normal));
// bent_normal = view_normal_to_world(bent_normal);

// TODO: Bent normal is buggy right now. Using world space normal instead
bent_normal = pixel_world_normal;

// Normalize values
accum /= max(1.0, accum_count);
accum *= 1.2;

result = vec4(bent_normal, 1 - saturate(accum));