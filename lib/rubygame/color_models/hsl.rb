require 'rubygame/color_models/base'
require 'rubygame/color_models/rgb'

module Rubygame
	module Color

		# Represents color in the HSL (Hue, Saturation, Luminosity) color space.
		class ColorHSL
			include ColorBase
			
			attr_reader :h, :s, :l, :a

			# call-seq:
			#   new( [h,s,l,a] )  ->  ColorHSL
			#   new( [h,s,l] )  ->  ColorHSL
			#   new( color )  ->  ColorHSL
			# 
			# Create a new instance from an Array or an existing color
			# (of any type). If the alpha (opacity) component is omitted
			# from the array, full opacity will be used.
			# 
			# h value is expected to range from 0 to 360.
			# s, l, a values are expected to range from 0.0 to 1.0.
			# 
			def initialize( color )
				if color.kind_of?(Array)
					@h, @s, @l, @a = color.collect { |i| i.to_f }
					@a = 1.0 unless @a
				elsif color.respond_to?(:to_rgba_ary)
					@h, @s, @l, @a = self.class.rgba_to_hsla( *color.to_rgba_ary )
				end
			end

			# Return an Array with the red, green, blue, and alpha components
			# of the color (converting the color to the RGBA model first).
			def to_rgba_ary
				return self.class.hsla_to_rgba( @h, @s, @l, @a )
			end
			
			class << self

				def new_from_rgba( rgba )
					new( rgba_to_hsla(*rgba) )
				end
				
				# Convert the red, green, blue, and alpha to the
				# equivalent hue, saturation, luminosity, and alpha.
				def rgba_to_hsla( r, g, b, a ) # :nodoc:
					rgb_arr = [r, g, b]
					max     = rgb_arr.max
					min     = rgb_arr.min

					# Calculate lightness.
					l = (max + min) / 2.0

					# Calculate saturation.
					if l == 0.0 or max == min
						s = 0
					elsif 0 < l and l <= 0.5 
						s = (max - min) / (max + min)
					else # l > 0.5
						s = (max - min) / (2 - (max + min))
					end
					
					# Calculate hue.
					if min == max 
						h = 0 
						# Undefined in this case, but set it to zero
					elsif max == r and g >= b
						h = (60 * (g - b) / (max - min)) + 0
					elsif max == r and g < b
						h = (60 * (g - b) / (max - min)) + 360
					elsif max == g
						h = (60 * (b - r) / (max - min)) + 120
					elsif max == b
						h = (60 * (r - g) / (max - min)) + 240
					else 
						raise "Should never happen"
					end 
					
					return [h,s,l,a]
				end
				
				# Convert the hue, saturation, luminosity, and alpha
				# to the equivalent red, green, blue, and alpha.
				def hsla_to_rgba( h, s, l, a ) # :nodoc:
					# If the color is achromatic, return already with the lightness value for all components
					if s == 0.0
						return [l, l, l, a]
					end

					# Otherwise, we have to do the long, hard calculation

					# q helper value
					q = (l < 0.5) ? (l * (1.0 + s)) : (l + s - l * s)

					# p helper value
					p = (2.0 * l) - q

					# hue normalized to [0...1) 
					hn = h / 360.0

					r = calculate_component( p, q, hn + 1.quo(3) )
					g = calculate_component( p, q, hn            )
					b = calculate_component( p, q, hn - 1.quo(3) )

					return [r,g,b,a]
				end

				private
				
				# Perform some arcane math to calculate a color component.
				def calculate_component(p, q, tc) # :nodoc:
					if tc < 1.quo(6)
						p + (q - p) * tc * 6.0
					elsif tc < 0.5
						q
					elsif tc < 2.quo(3)
						p + (q - p) * (2.quo(3) - tc) * 6.0
					else
						p 
					end
				end
				
			end

		end
	end
end
