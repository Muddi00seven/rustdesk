use base::message_proto::{Message, Misc, RemoteInputContext};
use hbb_common::{log, tokio::time::Instant};
use std::{ffi::c_void, sync::Arc};

use crate::server::Sender;

extern "C" {
    fn MacPilotStartInputContext(
        callback: extern "C" fn(*mut c_void, bool, bool),
        release: extern "C" fn(*mut c_void),
        context: *mut c_void,
    ) -> *mut c_void;
    fn MacPilotStopInputContext(context: *mut c_void);
}

pub struct InputContextObserver(*mut c_void);

// The pointer is only scheduled onto the native main queue, never dereferenced in Rust.
unsafe impl Send for InputContextObserver {}

impl InputContextObserver {
    pub fn start(sender: Sender) -> Self {
        let sender = Box::into_raw(Box::new(sender));
        Self(unsafe { MacPilotStartInputContext(changed, release, sender.cast()) })
    }
}

impl Drop for InputContextObserver {
    fn drop(&mut self) {
        unsafe { MacPilotStopInputContext(self.0) };
    }
}

extern "C" fn release(context: *mut c_void) {
    drop(unsafe { Box::from_raw(context.cast::<Sender>()) });
}

extern "C" fn changed(context: *mut c_void, editable: bool, secure: bool) {
    let sender = unsafe { &*context.cast::<Sender>() };
    let mut misc = Misc::new();
    misc.set_remote_input_context(RemoteInputContext {
        editable,
        secure,
        ..Default::default()
    });
    let mut message = Message::new();
    message.set_misc(misc);
    if sender.send((Instant::now(), Arc::new(message))).is_err() {
        log::trace!("Remote input context connection closed");
    }
}
