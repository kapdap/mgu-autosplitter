// Martian Gothic: Unification Auto Splitter
// By Kapdap 2020/08/27
// https://github.com/kapdap/mgu-autosplitter

state("martian gothic") {}

startup
{
    vars.splits = new ExpandoObject();
    vars.splits.endgame = false;

    settings.Add("events", true, "Events");
    settings.Add("endGame", true, "End Game", "events");

    // Application information
    settings.Add("infogroup", false, "Info");
    settings.Add("infogroup1", false, "Martian Gothic: Unification Auto Splitter by Kapdap", "infogroup");
    settings.Add("infogroup2", false, "Website: https://github.com/kapdap/mgu-autosplitter", "infogroup");
    settings.Add("infogroup3", false, "Last Update: 2020-08-27T22:45:00+1200", "infogroup");
}

init
{
	current.screen = 0;
	current.movie = 0;
	current.room = 0;
	current.endgame = 0;
}

start
{
    return (current.screen == 2 && current.movie == 1);
}

update
{
	current.screen = memory.ReadValue<byte>(new IntPtr(0x00752850));
	current.movie = memory.ReadValue<byte>(new IntPtr(0x005BD008));
	//current.room = memory.ReadValue<byte>(new IntPtr(0x005BB519));
	current.endgame = memory.ReadValue<byte>(new IntPtr(0x005C4708));
	
    if (timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.splits.endgame = false;
    }
}

split
{
    if (current.endgame == 0 && current.movie != 11 && !vars.splits.endgame)
    {
        vars.splits.endgame = true;
        return settings["endGame"];
    }
}

isLoading
{
    return false;
}