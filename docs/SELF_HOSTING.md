# Self-hosting preparation

Status: upstream client server configuration is retained; no server provisioned or MacPilot infrastructure accepted. Milestone 9 follows physical-session/input/trust milestones. The canonical default server policy is `upstream-compatible`; this does not provision or override a server.

RustDesk Server OSS uses `hbbs` for rendezvous and `hbbr` for relay. A Linux Docker Compose deployment with persistent server data is the upstream documented path. Native clients normally need TCP 21115–21117 and UDP 21116; Pro console 21114 and web-client 21118/21119 are separate. Keep web-client ports closed for this native-only deployment. [Official Docker guide](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/)

## Deployment work required

1. Choose the user's server/domain and region. Review capacity, data jurisdiction, firewall and budget before provisioning; none is selected yet.
2. Pin a reviewed server release/image digest. Keep persistent server keys/database outside ephemeral containers, with restrictive access and encrypted backups. Do not publish the private server key in Git or diagnostics.
3. Deploy `hbbs` and `hbbr` on the chosen Linux host using the pinned upstream deployment pattern. Permit only necessary native-client ports; document actual advertised rendezvous/relay addresses and DNS. No deployment commands are run by this checkpoint.
4. Distribute the verified public key through an authenticated channel. Configure ID server/key through the existing client network settings on both controller and host. Record the public fingerprint, not private material.
5. Validate registration, direct connection, forced relay, wrong public key, relay outage, rendezvous outage, changed network/IP and recovery on real devices. A server process merely listening is insufficient acceptance.
6. Test backup/restore while preserving identity, upgrade rollback and key-rotation notification. Never silently replace a trusted server identity during recovery.

The current upstream warning says directly exposed web-client WebSocket ports permit forged forwarded-IP headers. If web support is added later, restrict these ports to a reverse proxy that sets the client IP header itself. [Official installation warning](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/install/)

Do not remove encryption or authentication to diagnose network problems. Keep server administration separate from remote-Mac session authorization. Document the selected configuration and measured results here when milestone 9 is exercised.
