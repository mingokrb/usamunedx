local function on_seq_load(p, seqId)
   if Config.misc.music.value == 2 then
      return 0
   end
end
hook_event(HOOK_ON_SEQ_LOAD, on_seq_load)
