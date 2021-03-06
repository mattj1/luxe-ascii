import luxe.States;
import luxe.Vector;
import luxe_ascii.*;

class Demo extends State {
	var consoleBuffer:ConsoleBuffer;

    var textBuffer:TextBuffer;

    var sprite_logo:TextBuffer;
    var transparent_test:TextBuffer;

    var stars:Array<Star>;

    public function new() {
        super({name:'demo'});

        Luxe.camera.size = new Vector(640,350);

        // The ConsoleBuffer manages the geometry that renders the ASCII console
        consoleBuffer = new ConsoleBuffer( { 
        	width: 80, 
        	height: 25, 
        	fontFile:'assets/charmaps/cp437_8x14_terminal.png', 
        	glyph_width: 8, 
        	glyph_height:14, 
        	glyph_file_columns:16
        });      

        // Think of this as your "back buffer". Draw everything to this buffer, and when you're done,
        // update the ConsoleBuffer with it (See below).
        textBuffer = new TextBuffer(80, 25);

        // Example image created in REXPaint.
        sprite_logo = REXLoader.load('assets/xp/luxe_ascii_logo.xp');
        transparent_test = REXLoader.load('assets/xp/transparent_test.xp');

        stars = new Array<Star>();
        for(i in 0 ... 40) {
            var s:Star = new Star();
            s.x = Std.random(80);
            stars.push(s);
        }
    }

    override function update(dt:Float) {

    	// Update the starfield
        for(s in stars) {
            s.x += s.speed;
            if(s.x < 0) s.reset();
        }

        // Clear the buffer. This is optional, but since this example doesn't draw to every
        // character in the position, the stars will leave trails when they move.
		textBuffer.clear(ANSIColors.color(0));

		// Draw the starfield
		for(s in stars) {
            textBuffer.set_char(Std.int(s.x), Std.int(s.y), 7); 
            textBuffer.set_fg_color(Std.int(s.x), Std.int(s.y), s.c);
        }

        // Draw the title image
    	textBuffer.blit(sprite_logo, Std.int(textBuffer.width / 2 - sprite_logo.width / 2), 5);

        textBuffer.blit(transparent_test, 5, 4);

    	// Update the displayed geometry
    	consoleBuffer.blit(textBuffer);
    }
}