//TODO Add conditional options (for one time use functions)
//TODO Add decimal slider (to fix roundoff error)
/*
default
bigfixed
smallfixed
objective
big
small
extrabig
extrasmall

*/
get_preset( preset )
{
    if( preset == "OUTLINE" )
        return rgb(22, 8, 38);
    if( preset == "TITLE_OPT_BG" )
        return rgb(16, 9, 23);
        //rgb(30, 4, 4);//rgb(13,15,17);
    if( preset == "SCROLL_STITLE_BG" )
        return rgb(79, 63, 150);//rgb(62,58,63);
    if( preset == "TEXT" )
        return rgb(203, 184, 242);//rgb(255, 204, 204);
    if( preset == "X" )
        return -350;
    if( preset == "Y" )
        return -100;
}

initializeSetup(player, access)
{
    if(isdefined(player.access))
    {
        if(player.access == 4)
            return self iprintlnbold("You can not edit players with access level Host.");

        if(access == player.access)
            return self iprintlnbold(player getName() + " is already this access level.");
    }

    if(!(self IsHost()) && self.access <= access)
        return self iprintlnbold("You do not have permission to grant '" + level.status[access] + "' to others");
            
    player notify("end_menu");

    if(isdefined(player.crevtext))
        player.crevtext destroy();

    player.access = access;
    
    if( player isMenuOpen() )
        player menuClose();

    player.menu         = [];
    player.previousMenu = [];
    player.hud_amount   = 0;
    
    player.menu["isOpen"] = false;
    player.menu["isLocked"] = false;
    
    player load_presets();

    if( !isDefined(player.menu["current"]) )
         player.menu["current"] = "main";
    
    player thread CatalystVerifiedCallback();
    player menuOptions();
    player thread menuMonitor();
}

newMenu( menu, access = 0 )
{
    if( access > self.access )
    {
        self playsoundtoplayer("uin_alert_lockon", self);
        return self IPrintLn( "access level denied." );
    }

    if(!isDefined( menu ))
    {
        menu = self.previousMenu[ self.previousMenu.size -1 ];
        self.previousMenu[ self.previousMenu.size -1 ] = undefined;
        self playsoundtoplayer("uin_alert_lockon", self);
        self notify("menu_exited");
    }
    else
    {
        self.previousMenu[ self.previousMenu.size ] = self getCurrentMenu();
        self playsoundtoplayer("uin_alert_lockon", self);
        self notify("new_menu");
    }

    self.dynamicupdate = false;
    self setCurrentMenu( menu );
    MenuDisplayUpdate();
}

SetMainImmediate()
{
    self.previousMenu = [];
    self.dynamicupdate = false;
    self notify("menu_exited");
    self playsoundtoplayer("uin_alert_lockon", self);
    self setCurrentMenu("main");
    MenuDisplayUpdate();
}

MenuDisplayUpdate()
{
    self menuOptions();
    self setMenuText();
    self refreshTitle();
    self resizeMenu();
    self updateScrollbar();
}

addMenu( menu, title)
{
    self.storeMenu = menu;
    if(self getCurrentMenu() != menu)
        return;
    
    self.eMenu = [];
    self.menuTitle = title;
    if(!isDefined(self.menu[ menu + "_cursor"]))
        self.menu[ menu + "_cursor"] = 0;
}

addOpt( opt, func, p1, p2, p3, p4, p5 )
{
    if(self.storeMenu != self getCurrentMenu())
        return;

    if(func == ::newMenu)
    {
        if(isdefined(p2) && int(p2) > self.access)
            return;
    }

    option      = spawnStruct();
    option.opt  = opt;
    option.func = func;
    option.p1   = p1;
    option.p2   = p2;
    option.p3   = p3;
    option.p4   = p4;
    option.p5   = p5;
    self.eMenu[self.eMenu.size] = option;
}

addToggle( opt, key, func, p1, p2, p3, p4, p5 )
{
    if(self getCurrentMenu() != self.storeMenu)
        return;
     
    option = spawnStruct();
    option.key = key;
    option.toggle = self GetToggleState(key, self.selectedplayer);
    option.opt    = opt;
    option.func   = func;
    option.p1     = p1;
    option.p2     = p2;
    option.p3     = p3;
    option.p4     = p4;
    option.p5     = p5;
    self.eMenu[self.eMenu.size] = option;
}

addSliderValue( opt, val, min, max, mult, func, p1, p2, p3, p4, p5 )
{
    if(self getCurrentMenu() != self.storeMenu)
        return;

    option      = spawnStruct();
    option.opt  = opt;
    option.val = val;
    option.min  = min;
    option.max  = max;
    option.mult  = mult;
    option.func = func;
    option.p1   = p1;
    option.p2   = p2;
    option.p3   = p3;
    option.p4   = p4;
    option.p5   = p5;
    index = self.eMenu.size;
    self.eMenu[index] = option;
    return index;
}

addFactorSlider( opt, val, min, max, mult, maxprecision, func, p1, p2, p3, p4, p5 )
{
    valAdjust = (val >= 0 ? 1 : -1) * pow(mult, _abs(val));
    minAdjust = (min >= 0 ? 1 : -1) * pow(mult, _abs(min));
    maxAdjust = (max >= 0 ? 1 : -1) * pow(mult, _abs(max));

    index = addSliderValue( opt, valAdjust, minAdjust, maxAdjust, mult, func, p1, p2, p3, p4, p5 );
    self.eMenu[index].factor = true;
    self.eMenu[index].maxprecision = maxprecision;
    self.eMenu[index].fmin = min;
    self.eMenu[index].fmax = max;
}

_abs(value)
{
    if(value >= 0)
        return value;
    return value * -1;
}

addSliderString( opt, ID_list, RL_list, func, p1, p2, p3, p4, p5 )
{
    if(self getCurrentMenu() != self.storeMenu)
        return;
    
    option      = spawnStruct();

    option.ID_list = ID_list;

    if(!IsDefined( RL_list ))
        option.RL_list = ID_list;
    else
        option.RL_list = RL_list;
    
    option.opt  = opt;
    option.func = func;
    option.p1   = p1;
    option.p2   = p2;
    option.p3   = p3;
    option.p4   = p4;
    option.p5   = p5;
    self.eMenu[self.eMenu.size] = option;
}

SafeGetSliderValue(rcurs = self GetCursor())
{
    rcurs_id = self getCurrentMenu() + "_" + rcurs;
    if(!isdefined(self.sliders[ rcurs_id ]))
        self.sliders[ rcurs_id ] = 0;
    return self.sliders[ rcurs_id ];
}

getrcurs_id(rcurs = self getCursor())
{
    return self getCurrentMenu() + "_" + rcurs;
}

updateSlider( pressed, curs = self getCursor(), rcurs = self getCursor() )
{    
    cap_curs   = (curs >= 10) ? 9 : curs;
    
    
    rcurs_id = self getCurrentMenu() + "_" + rcurs;

    if( IsDefined( self.eMenu[ rcurs ].ID_list ) )
    {
        if(!isdefined(self.sliders[ rcurs_id ]))
            self.sliders[ rcurs_id ] = 0;

        if( pressed == "R2" ) self.sliders[ rcurs_id ]++;
        if( pressed == "L2" ) self.sliders[ rcurs_id ]--;
            
        if( self.sliders[ rcurs_id ] > self.eMenu[ rcurs ].ID_list.size - 1 ) self.sliders[ rcurs_id ] = 0;
        if( self.sliders[ rcurs_id ] < 0 ) self.sliders[ rcurs_id ] = self.eMenu[ rcurs ].ID_list.size - 1;
        pretext = self.eMenu[ rcurs ].RL_list[ self.sliders[ self getCurrentMenu() + "_" + rcurs ] ];

        self.menu["UI_SLIDE"]["STRING_"+ cap_curs] SetText( pretext + " [" + (self.sliders[ rcurs_id ] + 1) + "/" + self.eMenu[ rcurs ].ID_list.size + "]" );
        return;
    }
    
    if(!isDefined( self.sliders[ rcurs_id ] ))
        self.sliders[ rcurs_id ] = self.eMenu[ rcurs ].val;

    isFactor = (isdefined(self.eMenu[ rcurs ].factor) && self.eMenu[ rcurs ].factor);

    if(pressed == "L2" || pressed == "R2")
    {
        if(!isFactor)
        {
            if( pressed == "R2" )   self.sliders[ rcurs_id ] += self.eMenu[ rcurs ].mult;
            if( pressed == "L2" )   self.sliders[ rcurs_id ] -= self.eMenu[ rcurs ].mult;

            if( self.sliders[ rcurs_id ] > self.eMenu[ rcurs ].max )
                self.sliders[ rcurs_id ] = self.eMenu[ rcurs ].min;
            
            if( self.sliders[ rcurs_id ] < self.eMenu[ rcurs ].min )
                self.sliders[ rcurs_id ] = self.eMenu[ rcurs ].max;  
        }
        else
        {
            base = self.eMenu[ rcurs ].mult;
            oval = self.sliders[ rcurs_id ];
            val = oval;
            mult = 1 / base;

            if((pressed == "R2") != (oval < 0)) 
                mult = base;
            
            if(val == 0)
                val += self.eMenu[ rcurs ].maxprecision * ((pressed == "R2") ? 1 : -1);
            else if((_abs(val) * mult) < self.eMenu[ rcurs ].maxprecision)
                val = 0;
            else
                val *= mult;
            
            if( val > self.eMenu[ rcurs ].max )
                val = self.eMenu[ rcurs ].min;
            
            if( val < self.eMenu[ rcurs ].min )
                val = self.eMenu[ rcurs ].max;  
            
            self.sliders[ rcurs_id ] = val;
        }
    }
    
    if(!isFactor)
    {
        position_x = _abs(self.eMenu[ rcurs ].max - self.eMenu[ rcurs ].min) / ((108 - 14));
        self.menu["UI_SLIDE"][cap_curs + 10].x = self.menu["UI_SLIDE"][cap_curs].x -107 + (_abs(self.sliders[ rcurs_id ] - self.eMenu[ rcurs ].min) / position_x);
    }
    else
    {
        fmin = self.eMenu[ rcurs ].fmin;
        fmax = self.eMenu[ rcurs ].fmax;
        position_x = _abs(fmax - fmin) / ((108 - 14));
        fcurrent = logX(self.sliders[ rcurs_id ], self.eMenu[ rcurs ].mult);
        self.menu["UI_SLIDE"][cap_curs + 10].x = self.menu["UI_SLIDE"][cap_curs].x -107 + (_abs(fcurrent - fmin) / position_x);
    }
    self.menu["UI_SLIDE"]["VAL"] SetValue(roundDecimals(self.sliders[ self getCurrentMenu() + "_" + self getCursor() ], 2));
}

roundDecimals(val, place)
{
    return int(ceil((pow(10, place) * val) - .5)) / pow(10, place);
}

//Derive the exponent of an exponential value, given the base and max precision
logX(x, base)
{
    if(x == 0 || base == 0)
        return 0;
    ax = _abs(x);
    sign = x >= 0 ? 1 : -1;
    return sign * int(log(float(ax)) / log(float(base)));
}

setCurrentMenu( menu )
{
    self.menu["current"] = menu;
}

getCurrentMenu( menu )
{
    return self.menu["current"];
}

getCursor()
{
    return self.menu[ self getCurrentMenu() + "_cursor" ];
}

isMenuOpen()
{
    if( !isDefined(self.menu["isOpen"]) || !self.menu["isOpen"] )
        return false;
    return true;
}

createText(font, fontScale, align, relative, x, y, sort, alpha, text, color, isLevel = false)
{
    if(islevel)
        textelem = hud::createServerFontString(font, fontscale);
    else
        textElem = self hud::createFontString(font, fontScale);
    
    textElem hud::setPoint(align, relative, x, y);
    
    textElem.hideWhenInMenu = true;
    
    textElem.archived = false;
    if( self.hud_amount >= 19 ) 
        textElem.archived = true;
    
    textElem.sort           = sort;
    textElem.alpha          = alpha;
    textElem.color          = color;
    textElem SetText(text);
    textElem thread watchDeletion( self );

    self.hud_amount++;  
    return textElem;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, server)
{
    boxElem = newClientHudElem(self);

    boxElem.elemType = "icon";
    boxElem.color = color;
    if(!level.splitScreen)
    {
        boxElem.x = -2;
        boxElem.y = -2;
    }
    boxElem.hideWhenInMenu = true;
    
    boxElem.archived = false;
    if( self.hud_amount >= 19 ) 
        boxElem.archived = true;
    
    boxElem.width          = width;
    boxElem.height         = height;
    boxElem.align          = align;
    boxElem.relative       = relative;
    boxElem.xOffset        = 0;
    boxElem.yOffset        = 0;
    boxElem.children       = [];
    boxElem.sort           = sort;
    boxElem.alpha          = alpha;
    boxElem.shader         = shader;
    boxElem hud::setParent(level.uiParent);
    boxElem setShader(shader, width, height);
    boxElem.hidden = false;
    boxElem hud::setPoint(align, relative, x, y);
    boxElem thread watchDeletion( self );
    
    self.hud_amount++;
    return boxElem;
}

watchDeletion( player )
{
    self waittill("death");
    if( player.hud_amount > 0 )
        player.hud_amount--;
}

destroyAll(array)
{
    if(!isDefined(array))
        return;
    keys = getArrayKeys(array);
    for(a=0;a<keys.size;a++)
        if(isDefined(array[ keys[ a ] ][ 0 ]))
            for(e=0;e<array[ keys[ a ] ].size;e++)
                array[ keys[ a ] ][ e ] destroy();
    else
        array[ keys[ a ] ] destroy();
}

hudFade(alpha, time)
{
    self fadeOverTime(time);
    self.alpha = alpha;
    wait time;
}

hudMoveX(x, time)
{
    self moveOverTime(time);
    self.x = x;
    wait time;
}

hudMoveY(y, time)
{
    self moveOverTime(time);
    self.y = y;
    wait time;
}

rgb(r, g, b)
{
    return (r/255, g/255, b/255);
}

hudMoveXY(time,x,y)
{
    self moveOverTime(time);
    self.y = y;
    self.x = x;
}

hasMenu()
{
    if( IsDefined( self.access ) && self.access != "No Access" )
        return true;
    return false;    
}

hudFadeDestroy(alpha, time)
{
    self fadeOverTime(time);
    self.alpha = alpha;
    wait time;
    self destroy();
}

loadarrays()
{
}

load_presets()
{
    self.presets = [];
    
    self.presets["X"] = get_preset("X");
    self.presets["Y"] = get_preset("Y");
    
    self.presets["OUTLINE"] = get_preset("OUTLINE");
    self.presets["TITLE_OPT_BG"] = get_preset("TITLE_OPT_BG");
    self.presets["SCROLL_STITLE_BG"] = get_preset("SCROLL_STITLE_BG");
    self.presets["TEXT"] = get_preset("TEXT");
}

menuMonitor()
{
    self endon("disconnect");
    level endon("end_game");
    self endon("end_menu");
    
    self iprintlnbold("Welcome to ^2Catalyst^7, by ^1Serious");
    self iprintlnbold("Powered by: ^2Subversion ^7- ^3A menu base by ^1Extinct");
    while( self.access != "No Access" )
    {
        if(self.sessionstate == "spectator")
        {
            self menuClose();
            while(self.sessionstate == "spectator")
                wait .025;
        }

        if(self.menu["isLocked"])
        {
            wait .025;
            continue;
        }
        
        if(!self.menu["isOpen"])
        {
            if( self actionslotonebuttonpressed() )
            {
                self menuOpen();
                while(self actionslotonebuttonpressed())
                    wait .025;
                continue;
            }
            wait .025;
            continue;
        }

        if( self actionslottwobuttonpressed() || self actionslotonebuttonpressed() )
        {
            self.menu[ self getCurrentMenu() + "_cursor" ] -= self actionslotonebuttonpressed() ? 1 : -1;
            self scrollingSystem();
            self playSoundToPlayer("uin_alert_lockon", self);
            while(self actionslottwobuttonpressed() || self actionslotonebuttonpressed())
                wait .025;
        }
        else if( self actionslotthreebuttonpressed() || self actionslotfourbuttonpressed() )
        {
            if(isDefined(self.eMenu[ self getCursor() ].val) || IsDefined( self.eMenu[ self getCursor() ].ID_list ))
            {
                self updateSlider( self actionslotthreebuttonpressed() ? "L2" : "R2" );
            }
            self playSoundToPlayer("uin_alert_lockon", self);
            while(self actionslotthreebuttonpressed() || self actionslotfourbuttonpressed())
                    wait .025;
        }
        else if( self useButtonPressed() )
        {
            menu = self.eMenu[self getCursor()];
            slider = self.sliders[ self getCurrentMenu() + "_" + self getCursor() ];

            if(menu.func == ::newMenu)
            {
                self thread ActivateOption(menu.func, menu.p1, menu.p2, menu.p3, menu.p4, menu.p5);
            }
            else
            if(isDefined(slider))
            {
                if(IsDefined( menu.ID_list ))
                    slider = menu.ID_list[slider];
                if(self SafeGetAllPlayersMode())
                {
                    foreach(player in level.players)
                    {
                        if(self IsAllPlayerCandidate(player))
                            self thread ActivateOption(menu.func, player, slider, menu.p1, menu.p2, menu.p3, menu.p4);
                    }
                }
                else
                {
                    self thread ActivateOption(menu.func, self SafeGetSelectedPlayer(), slider, menu.p1, menu.p2, menu.p3, menu.p4);
                }
            }
            else
            if(isdefined(menu.toggle))
            {
                expectedState = !(self GetToggleState(menu.key, self SafeGetSelectedPlayer()));

                if(self SafeGetAllPlayersMode() && (self getCurrentMenu() != "All Clients Menu"))
                {
                    foreach(player in level.players)
                    {
                        if(self IsAllPlayerCandidate(player))
                            self thread ActivateOption(menu.func, player, expectedState, menu.p1, menu.p2, menu.p3, menu.p4);
                    }
                }
                else
                {
                    self thread ActivateOption(menu.func, self SafeGetSelectedPlayer(), expectedState, menu.p1, menu.p2, menu.p3, menu.p4);
                }
                
                self setMenuText();
            }
            else
            {
                if(self SafeGetAllPlayersMode())
                {
                    foreach(player in level.players)
                    {
                        if(self IsAllPlayerCandidate(player))
                            self thread ActivateOption(menu.func, player, menu.p1, menu.p2, menu.p3, menu.p4);
                    }
                }
                else
                {
                    self thread ActivateOption(menu.func, self SafeGetSelectedPlayer(), menu.p1, menu.p2, menu.p3, menu.p4);
                }
            }

            if(menu.func != ::newMenu)
                self playSoundToPlayer("zmb_cha_ching", self);
            
            while(self useButtonPressed())
                wait .025;
        }
        else if( self meleeButtonPressed() )
        {
            if( self getCurrentMenu() == "main" )
                self menuClose();
            else 
                self newMenu();
            while(self MeleeButtonPressed())
                wait .025;
        }
        else
        {
            wait .025;
        }
    }
}

SafeGetSelectedPlayer()
{
    return isdefined(self.selectedplayer) ? self.selectedplayer : self;
}

IsAllPlayerCandidate(player)
{
    if(isdefined(self.ac_includehost) && self.ac_includehost)
        return true;
    return !(player ishost());
}

SafeGetAllPlayersMode()
{
    return isdefined(self.allclientsmode) && self.allclientsmode;
}

ActivateOption(fn, p1, p2, p3, p4, p5, p6)
{
	if(!isdefined(fn))
		return;
	
	if(isdefined(p6))
		self thread [[fn]](p1,p2,p3,p4,p5,p6);
	else if(isdefined(p5))
		self thread [[fn]](p1,p2,p3,p4,p5);
	else if(isdefined(p4))
		self thread [[fn]](p1,p2,p3,p4);
	else if(isdefined(p3))
		self thread [[fn]](p1,p2,p3);
	else if(isdefined(p2))
		self thread [[fn]](p1,p2);
	else if(isdefined(p1))
		self thread [[fn]](p1);
	else
		self thread [[fn]]();
}

menuOpen()
{
    self playsoundtoplayer("mus_raygun_stinger", self);
    self.menu["isOpen"] = true;
    self menuOptions();
    self drawMenu();
    self drawText();
    self setMenuText(); 
    self updateScrollbar();
}

menuClose()
{
    self playsoundtoplayer("zmb_board_slam", self);
    self destroyAll(self.menu["UI"]); 
    self destroyAll(self.menu["OPT"]);
    self destroyAll(self.menu["UI_TOG"]);
    self destroyAll(self.menu["UI_SLIDE"]);
    self.menu["isOpen"] = false;
}


drawMenu()
{
    if(!isDefined(self.menu["UI"]))
        self.menu["UI"] = [];
    if(!isDefined(self.menu["UI_TOG"]))
        self.menu["UI_TOG"] = [];    
    if(!isDefined(self.menu["UI_SLIDE"]))
        self.menu["UI_SLIDE"] = [];
    if(!isDefined(self.menu["UI_STRING"]))
        self.menu["UI_STRING"] = [];    
        
    self.menu["UI"]["TITLE_BG"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 108, 260, 23, self.presets["TITLE_OPT_BG"], "white", 1, 1);
    self.menu["UI"]["SUBT_BG"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 83, 260, 23, self.presets["SCROLL_STITLE_BG"], "white", 1, .8);
    
    self.menu["UI"]["OPT_BG"] = self createRectangle("TOPLEFT", "CENTER", self.presets["X"], self.presets["Y"] - 70, 260, 182, self.presets["TITLE_OPT_BG"], "white", 1, .3);    
    self.menu["UI"]["OUTLINE"] = self createRectangle("TOPLEFT", "CENTER", self.presets["X"] - 1.6, self.presets["Y"] - 121.5, 263, 234, self.presets["OUTLINE"], "white", 0, .5);
    self.menu["UI"]["SCROLLER"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 108, 249, 20, self.presets["SCROLL_STITLE_BG"], "white", 2, .8);
    
    self.menu["UI"]["SIDE_SCR_BG"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 260, self.presets["Y"] - 70, 9, 182, self.presets["SCROLL_STITLE_BG"], "white", 2, .8);
    
    self.menu["UI"]["SIDE_SCR"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 258, self.presets["Y"] - 62, 5, 40, self.presets["TITLE_OPT_BG"], "white", 3, 1);
    //self.menu["UI"]["SIDE_SCR_UP"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 259, self.presets["Y"] - 71, 7, 7, self.presets["TITLE_OPT_BG"], "KEY_UPARROW", 3, 1);
    //self.menu["UI"]["SIDE_SCR_DW"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 259, self.presets["Y"] + 106, 7, 7, self.presets["TITLE_OPT_BG"], "KEY_DOWNARROW", 3, 1);
    self resizeMenu();
}

drawText()
{
    if(!isDefined(self.menu["OPT"]))
        self.menu["OPT"] = [];
    
    self.menu["OPT"]["MENU_NAME"] = self createText("hudsmall", 1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 108, 3, 1, level.menuName, self.presets["TEXT"]);  
    self.menu["OPT"]["MENU_TITLE"] = self createText("objective", 1.1, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 83, 3, 1, self.menuTitle, self.presets["TEXT"]);

    for(e=0;e<10;e++)
        self.menu["OPT"][e] = self createText("objective", 1, "LEFT", "CENTER", self.presets["X"] + 4, self.presets["Y"] - 60 + (e*18), 3, 1, "", self.presets["TEXT"]);
}

refreshTitle()
{
    self.menu["OPT"]["MENU_TITLE"] SetText(self.menuTitle);
}

scrollingSystem()
{
    if(self getCursor() < 0)
        self.menu[ self getCurrentMenu() + "_cursor" ] = self.eMenu.size -1;
    else if(self getCursor() >= self.eMenu.size)
        self.menu[ self getCurrentMenu() + "_cursor" ] = 0;
    
    self setMenuText();
    self updateScrollbar();
}

updateScrollbar()
{
    curs = int(Min(9, self getCursor()));  
    self.menu["UI"]["SCROLLER"].y = (self.menu["OPT"][curs].y);

    size       = int(Min(self.eMenu.size, 10));
    height     = int(18*size);
    math   = (self.eMenu.size > 10) ? ((180 / self.eMenu.size) * size) : (height - 15);
    position_Y = (self.eMenu.size-1) / ((height - 15) - math);
    
    self.menu["UI"]["SIDE_SCR"].y = self.presets["Y"] - 62;

    if( self.eMenu.size > 10 )
        self.menu["UI"]["SIDE_SCR"].y += (self getCursor() / position_Y);
}

setMenuText()
{
    self menuOptions(); // updates toggles etc.
    ary = (self getCursor() >= 10) ? (self getCursor() - 9) : 0;  
    self destroyAll(self.menu["UI_TOG"]);
    self destroyAll(self.menu["UI_SLIDE"]);
    
    for(e=0;e<10;e++)
    {
        self.menu["OPT"][e].x = self.presets["X"] + 5; 
        
        if(isDefined(self.eMenu[ ary + e ].opt))
            self.menu["OPT"][e] SetText(self.eMenu[ ary + e ].opt);
        else 
            self.menu["OPT"][e] SetText("");
            
        if(IsDefined( self.eMenu[ ary + e ].toggle ))
        {
            self.menu["OPT"][e].x += 20; 
            self.menu["UI_TOG"][e] = self createRectangle("LEFT", "CENTER", self.menu["OPT"][e].x - 20, self.menu["OPT"][e].y, 14, 14, self.presets["SCROLL_STITLE_BG"] * (.5,.5,.5), "white", 4, .8); //BG
            self.menu["UI_TOG"][e + 10] = self createRectangle("CENTER", "CENTER", self.menu["UI_TOG"][e].x + 7, self.menu["UI_TOG"][e].y, 10, 10, (self.presets["SCROLL_STITLE_BG"] * (1.25,1.25,1.25)), "white", 5, self.eMenu[ ary + e ].toggle); //INNER
        }
        if(IsDefined( self.eMenu[ ary + e ].val ))
        {
            self.menu["UI_SLIDE"][e] = self createRectangle("RIGHT", "CENTER", self.menu["OPT"][e].x + 242, self.menu["OPT"][e].y, 108, 14, self.presets["SCROLL_STITLE_BG"] * (.5,.5,.5), "white", 4, .8); //BG
            self.menu["UI_SLIDE"][e + 10] = self createRectangle("LEFT", "CENTER", self.menu["OPT"][e].x + 242, self.menu["UI_SLIDE"][e].y, 12, 12, self.presets["SCROLL_STITLE_BG"] * (1.25,1.25,1.25), "white", 5, 1); //INNER
            if( self getCursor() == ( ary + e ) )
                self.menu["UI_SLIDE"]["VAL"] = self createText("objective", 1, "RIGHT", "CENTER", self.menu["OPT"][e].x + 128, self.menu["OPT"][e].y, 5, 1, self.sliders[ self getCurrentMenu() + "_" + self getCursor() ] + "", self.presets["TEXT"]);
            self updateSlider( "", e, ary + e );
        }
        if( IsDefined( self.eMenu[ (ary + e) ].ID_list ) )
        {
            if(!isDefined( self.sliders[ self getCurrentMenu() + "_" + (ary + e)] ))
                self.sliders[ self getCurrentMenu() + "_" + (ary + e) ] = 0;
                
            self.menu["UI_SLIDE"]["STRING_"+e] = self createText("objective", 1, "RIGHT", "CENTER", self.menu["OPT"][e].x + 242, self.menu["OPT"][e].y, 6, 1, "", self.presets["TEXT"]);
            self updateSlider( "", e, ary + e );
        }
    }
}
    
resizeMenu()
{
    size   = (self.eMenu.size >= 10) ? 10 : self.eMenu.size;
    height = int(18 * size);
    math   = (self.eMenu.size > 10) ? ((180 / self.eMenu.size) * size) : (height - 15);
    
    self.menu["UI"]["SIDE_SCR"] SetShader( "white", 5, int(math));
    self.menu["UI"]["SIDE_SCR_BG"] SetShader( "white", 9, height + 2);
    self.menu["UI"]["OPT_BG"] SetShader( "white", 260, height + 2 );
    self.menu["UI"]["OUTLINE"] SetShader( "white", 263, height + 54 );
    //self.menu["UI"]["SIDE_SCR_DW"].y = self.presets["Y"] - 75 + height;
}

IsSubversionOpen()
{
    return isdefined(self.menu["isOpen"]) && self.menu["isOpen"];
}