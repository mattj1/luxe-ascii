package luxe_ascii;

import luxe.Color;
import snow.api.buffers.*;
import luxe.Rectangle;

typedef BlitOptions = {
	fg:Int,
	bg:Int,
	char:Int
};

class TextBuffer {
	
	public var width:Int;
	public var height:Int;

	public var data:Array<CharAttr>;

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;

		data = new Array<CharAttr>();

		for(i in 0 ... width * height) {
			data.push(new CharAttr());
		}
	}

	public function set_char(x:Int, y:Int, ch:Int) {
		if(x < 0 || y < 0 || x >= width || y >= height || ch < 0 || ch > 255)
			return;

		data[y * width + x].char = ch;
	}

	public function set_transparent(x:Int, y:Int, isTransparent:Bool) {
		if(x < 0 || y < 0 || x >= width || y >= height)
			return;

		if(isTransparent)
			data[y * width + x].attr |= 0x02;
		else 
			data[y * width + x].attr &= ~0x02;
	}

	public function set_fg_color(x:Int, y:Int, color:Color) {
		if(x < 0 || y < 0 || x >= width || y >= height)
			return;
		
		data[y * width + x].fg = color;
	}

	public function set_bg_color(x:Int, y:Int, color:Color) {
		if(x < 0 || y < 0 || x >= width || y >= height)
			return;
		
		data[y * width + x].set_bg_color(color);
	}

	// Draw a TextBuffer onto this one at (xPos, yPos), taking into account transparency.
	public function blit(t:TextBuffer, xPos:Int, yPos:Int) {

		if(t == null) {
			return;
		}
		
	 	var dx:Int, dy:Int;
	 	var src_data:CharAttr, dst_data:CharAttr;

		for(y in 0 ... t.height) {
			dy = y + yPos;
			
			// Fit within Y bounds
			if(dy < 0 || dy >= height)
				continue;

			for(x in 0 ... t.width) {
				dx = x + xPos;
				
				// Fit within X bounds
				if(dx < 0 || dx >= width)
					continue;

				src_data = t.data[y * t.width + x];
				dst_data = data[dy * width + dx];

				// Don't modify this position if the source data is marked transparent.
				if(src_data.attr & 0x02 != 0)
					continue;

				dst_data.fg = src_data.fg;

				dst_data.char = src_data.char;
				dst_data.bg[0] = src_data.bg[0];
				dst_data.bg[1] = src_data.bg[1];
				dst_data.bg[2] = src_data.bg[2];
				dst_data.attr = src_data.attr;
			}
		}
	}

	public function darken(_x:Int, _y:Int, w:Int, h:Int) {

		for(y in _y ... _y + h) {
			for(x in _x ... _x + w) {
				var d = data[y * width + x];

				d.fg.r *= 0.5;
				d.fg.g *= 0.5;
				d.fg.b *= 0.5;

				d.bg[0] >>= 1;
				d.bg[1] >>= 1;
				d.bg[2] >>= 1;		
			}
		}
	}

	public function grayscale(_x:Int, _y:Int, w:Int, h:Int, ?amount:Float = 1.0) {

		for(y in _y ... _y + h) {
			for(x in _x ... _x + w) {
				var d = data[y * width + x];

				var f:Float = d.fg.r * 0.3 + d.fg.g * 0.6 + d.fg.b * 0.11;

				d.fg.r = amount * f + (1 - amount) * d.fg.r;
				d.fg.g = amount * f + (1 - amount) * d.fg.g;
				d.fg.b = amount * f + (1 - amount) * d.fg.b;

				d.bg[0] >>= 1;
				d.bg[1] >>= 1;
				d.bg[2] >>= 1;		
			}
		}
	}

	public function clear(c:Color) {
		for(i in 0 ... width * height) {

			var d:CharAttr = data[i];
			d.fg.r = 0;
			d.fg.g = 0;
			d.fg.b = 0;

			d.char = 0;
			d.bg[0] = Std.int(c.r * 255);
			d.bg[1] = Std.int(c.g * 255);
			d.bg[2] = Std.int(c.b * 255);
		}
	}

	public function writeString(xPos:Int, yPos:Int, str:String, fg:Color, bg:Color, ?options:BlitOptions) {
		var x:Int;

		for(i in 0 ... str.length) {
			x = xPos + i;

			if(x >= width)
				return;

			var d:CharAttr = data[yPos * width + x];

			d.char = str.charCodeAt(i);
			
			if(fg != null)
				d.fg = fg;
			
			if(bg != null)
				d.set_bg_color(bg);
		}
	}
}