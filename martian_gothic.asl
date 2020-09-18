// Martian Gothic: Unification Auto Splitter
// By Kapdap 2020/08/27
// https://github.com/kapdap/mgu-autosplitter

state("martian gothic") {}

startup
{
    vars.frame = new ExpandoObject();
    vars.frame.newgame = 0;
    vars.frame.opening = 0;
    
    vars.splits = new ExpandoObject();
    vars.splits.newgame = false;
    vars.splits.endgame = false;
    
    settings.Add("events", true, "Events");
    settings.Add("endgame", true, "End Game", "events");
    
    settings.Add("timer", true, "Start Timer");
    settings.Add("newgame", true, "New Game", "timer");
    settings.SetToolTip("newgame", "Start the timer as soon as New Game is selected.");
    settings.Add("opening", false, "Opening Dialog", "timer");
    settings.SetToolTip("opening", "Start the timer when Kenzo speaks his opening dialog.");

    // Application information
    settings.Add("infogroup", false, "Info");
    settings.Add("infogroup1", false, "Martian Gothic: Unification Auto Splitter by Kapdap", "infogroup");
    settings.Add("infogroup2", false, "Website: https://github.com/kapdap/mgu-autosplitter", "infogroup");
    settings.Add("infogroup3", false, "Last Update: 2020-09-16T10:25:00+1200", "infogroup");
}

init
{
    current.frames = 0;
    current.room = 0;
    current.movie = 0;
    current.screen = 0;
    current.switches = 0;
}

start
{
    if (settings["newgame"])
    {
        if (current.screen == 2 && (current.movie == 0 || current.movie == 1))
        {
            vars.frame.newgame = memory.ReadValue<int>(new IntPtr(0x005BCF64));
            return true;
        }
    }
    else
    {
        if (current.frames >= 20000)
        {
            vars.frame.newgame = memory.ReadValue<int>(new IntPtr(0x005BCF64));
            return true;
        }
    }
}

update
{
    current.frames = memory.ReadValue<int>(new IntPtr(0x005BCF64));
    current.room = memory.ReadValue<byte>(new IntPtr(0x005BB519));
    current.movie = memory.ReadValue<byte>(new IntPtr(0x005BD008));
    current.screen = memory.ReadValue<byte>(new IntPtr(0x00752850));
    current.switches = memory.ReadValue<byte>(new IntPtr(0x005C4708));

    if (timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.frame.newgame = 0;
        vars.frame.opening = 0;
        
        vars.splits.newgame = false;
        vars.splits.endgame = false;
    }
}

split
{
    if (!vars.splits.newgame)
        vars.splits.newgame = current.switches == 1;

    if (vars.splits.newgame)
    {
        if (current.switches == 0 && current.room == 28 && !vars.splits.endgame)
        {
            vars.splits.endgame = true;
            return settings["endgame"];
        }
    }
}

gameTime
{
    int frames = current.frames;
    
    if (settings["newgame"])
    {
        if (current.frames < 20000)
        {
            vars.frame.opening = current.frames;
            frames -= vars.frame.newgame;
        }
        else if (current.frames >= 20000)
        {
            frames -= 20000;
            frames += vars.frame.opening - vars.frame.newgame;
        }
    }
    else
    {
        frames -= 20000;
        frames += 6; // Syncs with Real Time
    }
    
    return TimeSpan.FromSeconds(frames / 30.0);
}

isLoading
{
    return true;
}