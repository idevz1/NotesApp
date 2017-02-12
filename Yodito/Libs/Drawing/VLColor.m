
#import "VLColor.h"
#import "VLUIObjects+Categories.h"
#import "../Common/Classes.h"

@implementation VLColor

@synthesize red = _red;
@synthesize green = _green;
@synthesize blue = _blue;
@synthesize alpha = _alpha;
@dynamic lightness;
@dynamic saturation;
@dynamic hue;

- (id)init
{
	self = [super init];
	if(self)
	{
		_alpha = 1.0;
	}
	return self;
}

- (id)initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
	self = [super init];
	if(self)
	{
		_red = red;
		_green = green;
		_blue = blue;
		_alpha = alpha;
	}
	return self;
}

+ (VLColor*)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
	VLColor *res = [[[VLColor alloc] initWithRed:red green:green blue:blue alpha:alpha] autorelease];
	return res;
}

+ (VLColor*)randomColor
{
	float r = (rand() % 256) / 255.0;
	float g = (rand() % 256) / 255.0;
	float b = (rand() % 256) / 255.0;
	return [VLColor colorWithRed:r green:g blue:b alpha:1.0];
}

- (VLColor*)lightUp:(float)value
{
	value = MAX(MIN(value, 1.0), 0);
	float curVal = self.lightness;
	float newVal = curVal + (1.0 - curVal) * value;
	VLColor *res = [[self copy] autorelease];
	res.lightness = newVal;
	return res;
}

- (VLColor*)darkOut:(float)value
{
	value = MAX(MIN(value, 1.0), 0);
	float curVal = self.lightness;
	float newVal = curVal - curVal * value;
	VLColor *res = [[self copy] autorelease];
	res.lightness = newVal;
	return res;
}

static void HSL2RGB(float h, float sl, float l, float* outR, float* outG, float* outB)
{
	if(sl == 0.0)
	{
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
	float v;
	float r,g,b;
	
	r = l;   // default to gray
	g = l;
	b = l;
	v = (l <= 0.5) ? (l * (1.0 + sl)) : (l + sl - l * sl);
	if (v > 0)
	{
		double m;
		double sv;
		int sextant;
		double fract, vsf, mid1, mid2;
		
		m = l + l - v;
		sv = (v - m ) / v;
		h *= 6.0;
		sextant = (int)h;
		fract = h - sextant;
		vsf = v * sv * fract;
		mid1 = m + vsf;
		mid2 = v - vsf;
		//////////////////
		if(sextant >= 6)
			sextant -= 6;
		//////////////////
		switch (sextant)
		{
			case 0:
				r = v;
				g = mid1;
				b = m;
				break;
			case 1:
				r = mid2;
				g = v;
				b = m;
				break;
			case 2:
				r = m;
				g = v;
				b = mid1;
				break;
			case 3:
				r = m;
				g = mid2;
				b = v;
				break;
			case 4:
				r = mid1;
				g = m;
				b = v;
				break;
			case 5:
				r = v;
				g = m;
				b = mid2;
				break;
		}
	}
	if(outR)
		*outR = r;
	if(outG)
		*outG = g;
	if(outB)
		*outB = b;
}


static void RGB2HSL(float r, float g, float b, float* outH, float* outS, float* outL)
{
	float v;
	float m;
	float vm;
	float r2, g2, b2;
	
	float h,s,l;
	
	h = 0; // default to black
	s = 0;
	l = 0;
	if(outH)
		*outH = h;
	if(outS)
		*outS = s;
	if(outL)
		*outL = l;
	v = MAX(r,g);
	v = MAX(v,b);
	m = MIN(r,g);
	m = MIN(m,b);
	l = (m + v) / 2.0;
	if (l <= 0.0)
	{
		return;
	}
	vm = v - m;
	s = vm;
	if (s > 0.0)
	{
		s /= (l <= 0.5) ? (v + m ) : (2.0 - v - m) ;
	}
	else
	{
		return;
	}
	r2 = (v - r) / vm;
	g2 = (v - g) / vm;
	b2 = (v - b) / vm;
	if (r == v)
	{
		h = (g == m ? 5.0 + b2 : 1.0 - g2);
	}
	else if (g == v)
	{
		h = (b == m ? 1.0 + r2 : 3.0 - b2);
	}
	else
	{
		h = (r == m ? 3.0 + g2 : 5.0 - r2);
	}
	h /= 6.0;
	
	if(outH)
		*outH = h;
	if(outS)
		*outS = s;
	if(outL)
		*outL = l;
}

- (void)getHue:(float*)hue
	saturation:(float*)saturation
	lightness:(float*)lightness
{
	RGB2HSL(_red, _green, _blue, hue, saturation, lightness);
}

- (void)setHue:(float)hue
	saturation:(float)saturation
	lightness:(float)lightness
{
	HSL2RGB(hue, saturation, lightness, &_red, &_green, &_blue);
}

- (float)lightness
{
	if(_red == _green && _green == _blue)
		return _red;
	if((!_red && !_green) || (!_green && !_blue) || (!_blue && !_red))
	{
		if(_red)
			return _red;
		if(_green)
			return _green;
		if(_blue)
			return _blue;
	}
	float lightness = 0;
	[self getHue:nil saturation:nil lightness:&lightness];
	return lightness;
}

- (void)setLightness:(float)value
{
	value = MAX(MIN(value, 1.0), 0);
	if(_red == _green && _green == _blue)
	{
		_red = _green = _blue = value;
		return;
	}
	if((!_red && !_green) || (!_green && !_blue) || (!_blue && !_red))
	{
		if(_red)
			_red = value;
		if(_green)
			_green = value;
		if(_blue)
			_blue = value;
		return;
	}
	float hue, saturation, lightness;
	[self getHue:&hue saturation:&saturation lightness:&lightness];
	[self setHue:hue saturation:saturation lightness:value];
}

- (float)saturation
{
	if(_red == _green && _green == _blue)
		return 0;
	if((!_red && !_green) || (!_green && !_blue) || (!_blue && !_red))
	{
		return 1.0;
	}
	float saturation = 0;
	[self getHue:nil saturation:&saturation lightness:nil];
	return saturation;
}

- (void)setSaturation:(float)value
{
	value = MAX(MIN(value, 1.0), 0);
	if(_red == _green && _green == _blue)
	{
		return;
	}
	if((!_red && !_green) || (!_green && !_blue) || (!_blue && !_red))
	{
		return;
	}
	float hue, saturation, lightness;
	[self getHue:&hue saturation:&saturation lightness:&lightness];
	[self setHue:hue saturation:value lightness:lightness];
}

- (float)hue
{
	float hue = 0;
	[self getHue:&hue saturation:nil lightness:nil];
	return hue;
}

- (void)setHue:(float)value
{
	value = MAX(MIN(value, 1.0), 0);
	float hue, saturation, lightness;
	[self getHue:&hue saturation:&saturation lightness:&lightness];
	[self setHue:value saturation:saturation lightness:lightness];
}

- (UIColor*)toUIColor
{
	return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}

+ (VLColor*)fromUIColor:(UIColor*)other
{
	CGFloat comps[4];
	[other getRGBAComponents:&comps[0]];
	VLColor *res = [[VLColor new] autorelease];
	res.red = comps[0];
	res.green = comps[1];
	res.blue = comps[2];
	res.alpha = comps[3];
	return res;
}

- (void)assignFrom:(VLColor*)other
{
	self.red = other.red;
	self.green = other.green;
	self.blue = other.blue;
	self.alpha = other.alpha;
}

- (BOOL)isEqual:(id)object
{
	VLColor *other = ObjectCast(object, VLColor);
	if(!other)
		return NO;
	return self.red == other.red && self.green == other.green &&
		self.blue == other.blue && self.alpha == other.alpha;
}

- (id)copyWithZone:(NSZone*)zone
{
	VLColor *other = [[VLColor allocWithZone:zone] init];
	[other assignFrom:self];
	return other;
}

- (void)dealloc
{
	[super dealloc];
}

@end

