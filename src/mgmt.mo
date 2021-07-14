// The IC Management Canister.
// For more information: https://sdk.dfinity.org/docs/interface-spec/index.html#ic-management-canister
module {
	// Canister identifier (principal).
	public type canister_id = Principal;

	// User identifier (principal).
	public type user_id = Principal;

	// WASM module blob type.
	public type wasm_module = [Nat8];

	// Settings of a canister.
	public type canister_settings = {
		// A list of principles. Must be between 0 and 10 in size. This value is 
		// assigned to the controllers attribute of the canister.
		// Default: A list containing only the caller of the create_canister call.
		controllers : ?[Principal];
		// Must be a number between 0 and 100, inclusively. It indicates how much
		// compute power should be guaranteed to this canister, expressed as a percentage
		// of the maximum compute power that a single canister can allocate.
		// Default: 0.
		compute_allocation : ?Nat;
		// Must be a number between 0 and 2^48 (i.e 256TB), inclusively. It indicates
		// how much memory the canister is allowed to use in total.
		// If set to 0, then memory growth of the canister will be best-effort and
		// subject to the available memory on the network.
		// Default: 0.
		memory_allocation : ?Nat;
		// Must be a number between 0 and 2^64-1, inclusively, and indicates a length
		// of time in seconds. A canister is considered frozen whenever the system
		// estimates that the canister would be depleted of cycles before freezing_threshold
		// seconds pass, given the canister’s current size and the system’s current cost for storage.
		// Default value: 2592000 (approximately 30 days).
		freezing_threshold : ?Nat;
	};

	// Definite version of `canister_settings`.
	public type definite_canister_settings = {
		controllers : [Principal];
		compute_allocation : Nat;
		memory_allocation : Nat;
		freezing_threshold : Nat;
	};

	public type Self = actor {
		// Register canister with the system, to get a canister id (with an empty
		// canister behind it).
		create_canister : shared { 
			// Optional settings to configure the new canister.
			settings : ?canister_settings;
		} -> async {
			// Identifier of the newly created canister.
			canister_id : canister_id;
		};

		// Update canister settings.
		// Access: Controllers
		update_settings : shared {
			// The identifier of the canister to update.
			canister_id : Principal;
			// Settings to update. Not including a setting in the settings 
			// record means not changing that field.
			settings : canister_settings;
		} -> async ();

		// Installs code into a canister.
		// Access: Controllers
		install_code : shared {
			// Installation arguments.
			arg : [Nat8];
			// WASM module to install.
			wasm_module : wasm_module;
			// Installation mode.
			mode : { 
				// Instantiates the canister module and invoke its `canister_init` 
				// system method (if present). The canister must be empty before. 
				#install;
				// Its existing code and state is removed before proceeding as 
				// for mode = install.
				#reinstall;
				// Performs an upgrade of a non-empty canister, passing arg to the 
				// `canister_post_upgrade` system method of the new instance.
				#upgrade;
			};
			// The identifier of the canister to install.
			canister_id : canister_id;
		} -> async ();

		// Removes a canister’s code and state, making the canister empty again.
		// Access: Controllers
		uninstall_code : shared {
			// The identifier of the canister to uninstall.
			canister_id : canister_id;
		} -> async ();

		// Indicates various information about the canister.
		canister_status : shared { canister_id : canister_id } -> async {
			// The status of the canister. It could be one of:
			// running, stopping or stopped.
			status : { #stopped; #stopping; #running };
			// The memory size taken by the canister.
			memory_size : Nat;
			// The cycle balance of the canister.
			cycles : Nat;
			// The settings of the canister.
			settings : definite_canister_settings;
			// A SHA256 hash of the module installed on the canister. This is null 
			// if the canister is empty.
			module_hash : ?[Nat8];
		};

		// Stop a canister (e.g., to prepare for a canister upgrade).
		// Access: Controllers
		stop_canister : shared {
			// The identifier of the canister to stop.
			canister_id : canister_id;
		} -> async ();

		// Start a canister.
		// Access: Controllers
		start_canister : shared {
			// The identifier of the canister to start.
			canister_id : canister_id;
		} -> async ();

		// Deletes a canister from the IC. The canister must already be stopped. 
		// Access: Controllers
		delete_canister : shared {
			// The identifier of the canister to delete.
			canister_id : canister_id;
		} -> async ();

		// Deposits the cycles included in this call into the specified canister.
		deposit_cycles : shared {
			// The identifier of the canister to deposit to.
			canister_id : canister_id
		} -> async ();

		// Returns 32 pseudo-random bytes to the caller.
		raw_rand : shared () -> async [Nat8];

		// These method is only available in local development instances, and 
		// will be REMOVED in the future.

		// Behaves as create_canister, but initializes the canister’s balance
		// with amount fresh cycles.
		provisional_create_canister_with_cycles : shared {
			// Optional settings to configure the new canister.
			settings : ?canister_settings;
			// Using MAX_CANISTER_BALANCE if amount = null, else capping the 
			// balance at MAX_CANISTER_BALANCE.
			amount : ?Nat;
		} -> async { 
			// Identifier of the newly created canister.
			canister_id : canister_id;
		};

		// Adds a certain amount cycles to the balance of canister.
		provisional_top_up_canister : shared {
			// Identifier of the canister to top up with cycles.
			canister_id : canister_id;
			// Amount of cycles (implicitly capping it at MAX_CANISTER_BALANCE).
			amount : Nat;
		} -> async ();
	}
}
