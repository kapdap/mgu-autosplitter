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

    settings.Add("patches", true, "Patches");
    settings.Add("disablebackmenu", false, "Disable Back Button to Menu", "patches");

    // Application information
    settings.Add("infogroup", false, "Info");
    settings.Add("infogroup1", false, "Martian Gothic: Unification Auto Splitter by Kapdap", "infogroup");
    settings.Add("infogroup2", false, "Website: https://github.com/kapdap/mgu-autosplitter", "infogroup");
    settings.Add("infogroup3", false, "Last Update: 2020-10-13T16:00:00+1200", "infogroup");

    vars.disablebackmenu = new ExpandoObject();
    vars.disablebackmenu.original = new byte[7]{ 0x80, 0x3D, 0x1E, 0xD0, 0x5B, 0x00, 0x01 };
    vars.disablebackmenu.modified = new byte[7]{ 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90 };
}

init
{
    current.menucheck = new ExpandoObject();
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
    current.menucheck = memory.ReadBytes(new IntPtr(0x00411C0F), 7);

    if (settings["disablebackmenu"])
    {
        bool changed = false;

        for (int i = 0; i < current.menucheck.Length; i++)
        {
            if (current.menucheck[i] == vars.disablebackmenu.modified[i])
            {
                changed = true;
                break;
            }
        }

        if (!changed)
        {
            print("disablebackmenu");
            bool write = memory.WriteBytes(new IntPtr(0x00411C0F), (byte[])vars.disablebackmenu.modified);
        }
    }
    else
    {
        bool changed = false;

        for (int i = 0; i < current.menucheck.Length; i++)
        {
            if (current.menucheck[i] == vars.disablebackmenu.original[i])
            {
                changed = true;
                break;
            }
        }

        if (!changed)
        {
            print("enablebackmenu");
            bool write = memory.WriteBytes(new IntPtr(0x00411C0F), (byte[])vars.disablebackmenu.original);
        }
    }

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