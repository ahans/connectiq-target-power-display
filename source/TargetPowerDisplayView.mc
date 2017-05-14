using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class TargetPowerDisplayView extends Ui.DataField {

    hidden var mValue;
    hidden var mMinPwr;
    hidden var mMaxPwr;
    
    hidden var mPwrValues;
    hidden var mIdx;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        
        mMinPwr = 190;
        mMaxPwr = 245;
        
        mPwrValues = new [10];
        mIdx = 0;
        
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :currentPower){
            if(info.currentPower != null) {
            	mPwrValues[mIdx % 10] = info.currentPower;
            	mIdx = mIdx + 1;
            	if (mIdx >= 10) {
            		mValue = 0;
            		for (var i = 0; i < 10; i++) {
            			mValue += mPwrValues[i];
            		}
            		mValue = mValue / 10.0f;
            	}
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    	var bgColor;
    	bgColor = Gfx.COLOR_WHITE;
		var meanPwr = mMinPwr + (mMaxPwr - mMinPwr) / 2.0f;
		if (mValue < mMinPwr) {
			bgColor = 0xffffff;
		} else if (mValue > mMaxPwr) {
			bgColor = 0xff0000;
		} else {
			var pwrDeviation = 0xff * ((mValue - meanPwr) / ((mMaxPwr - mMinPwr) / 2.0f)); // ranges from -255..255
			pwrDeviation = pwrDeviation.toLong();
			if (pwrDeviation < 0) {
				bgColor = ((0x00 - pwrDeviation) << 16) | ((0xff) << 8) | (0x00 - pwrDeviation);
			} else if (pwrDeviation < 40) {
				bgColor = 0x00ff00;
			} else {
				bgColor = ((0xff               ) << 16) | ((0xff - pwrDeviation) << 8) | (0xff - pwrDeviation);
			}
		}

        // Set the background color
        View.findDrawableById("Background").setColor(bgColor);

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        value.setColor(Gfx.COLOR_BLACK);
        value.setText(mValue.format("%.2f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
