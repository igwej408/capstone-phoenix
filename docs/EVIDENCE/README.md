# EVIDENCE

Drop screenshots/logs here, named so a grader knows what each proves:

- `nodes-ready.png` — multi-node `kubectl get nodes`
joseph@Joe:~/capstone-phoenix$ kubectl get nodes
NAME            STATUS   ROLES           AGE     VERSION
ip-10-0-1-126   Ready    <none>          5h43m   v1.35.5+k3s1
ip-10-0-1-136   Ready    control-plane   5h48m   v1.35.5+k3s1
ip-10-0-1-227   Ready    <none>          3h57m   v1.35.5+k3s1

- `pods-spread.png` — replicas on different nodes (`-o wide`)
joseph@Joe:~/capstone-phoenix$ kubectl get pods -n taskapp -o wide
NAME                                READY   STATUS      RESTARTS     AGE    IP           NODE            NOMINATED NODE   READINESS GATES
postgres-0                          1/1     Running     0     158m   10.42.1.3    ip-10-0-1-126   <none>           <none>
taskapp-backend-8449b59958-95bdb    1/1     Running     0     19m    10.42.0.38   ip-10-0-1-136   <none>           <none>
taskapp-backend-8449b59958-tbz5r    1/1     Running     0     19m    10.42.2.13   ip-10-0-1-227   <none>           <none>
taskapp-frontend-79798b4c89-dv6ds   1/1     Running     9 (83m ago)   141m   10.42.0.30   ip-10-0-1-136   <none>           <none>
taskapp-frontend-79798b4c89-qrcfq   1/1     Running     0     142m   10.42.2.5    ip-10-0-1-227   <none>           <none>
taskapp-migration-wmzf6             0/1     Completed   0     145m   10.42.2.4    ip-10-0-1-227   <none>           <none>


- `tls-valid.png` — valid cert (curl -vI / SSL Labs)

joseph@Joe:~/capstone-phoenix$ curl -vI https://josephigwe.duckdns.org 2>&1 | head -40
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- -  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0* Host josephigwe.duckdns.org:443 was resolved.
* IPv6: (none)
* IPv4: 13.61.1.134
*   Trying 13.61.1.134:443...
* Connected to josephigwe.duckdns.org (13.61.1.134) port 443
* ALPN: curl offers h2,http/1.1
} [5 bytes data]
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
} [512 bytes data]
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
{ [5 bytes data]
* TLSv1.3 (IN), TLS handshake, Server hello (2):
{ [122 bytes data]
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
{ [19 bytes data]
* TLSv1.3 (IN), TLS handshake, Certificate (11):
{ [4090 bytes data]
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
{ [264 bytes data]
* TLSv1.3 (IN), TLS handshake, Finished (20):
{ [52 bytes data]
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
} [1 bytes data]
* TLSv1.3 (OUT), TLS handshake, Finished (20):
} [52 bytes data]
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519 / RSASSA-PSS
* ALPN: server accepted h2
* Server certificate:
*  subject: CN=josephigwe.duckdns.org
*  start date: Jun 21 17:47:06 2026 GMT
*  expire date: Sep 19 17:47:05 2026 GMT
*  subjectAltName: host "josephigwe.duckdns.org" matched cert's "josephigwe.duckdns.org"
*  issuer: C=US; O=Let's Encrypt; CN=YR1
*  SSL certificate verify ok.
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
*   Certificate level 1: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
*   Certificate level 2: Public key type RSA (4096/152 Bits/secBits), signed using sha256WithRSAEncryption


- `pvc-persist.log` — data survives a Pod kill

joseph@Joe:~/capstone-phoenix$ kubectl get pods -n taskapp | grep postgres
postgres-0                          1/1     Running     0             165m
joseph@Joe:~/capstone-phoenix$ kubectl delete pod postgres-0 -n taskapp
pod "postgres-0" deleted from taskapp namespace
joseph@Joe:~/capstone-phoenix$ kubectl get pods -n taskapp -w
NAME                                READY   STATUS      RESTARTS      AGE
postgres-0                          1/1     Running     0             12s
taskapp-backend-8449b59958-95bdb    1/1     Running     0             26m
taskapp-backend-8449b59958-tbz5r    1/1     Running     0             26m
taskapp-frontend-79798b4c89-dv6ds   1/1     Running     9 (91m ago)   149m
taskapp-frontend-79798b4c89-qrcfq   1/1     Running     0             149m
taskapp-migration-wmzf6             0/1     Completed   0             152m
joseph@Joe:~/capstone-phoenix$ curl -I https://josephigwe.duckdns.org/api/healthth
HTTP/2 200 
date: Sun, 21 Jun 2026 21:07:48 GMT
content-type: application/json
content-length: 85
access-control-allow-origin: *
strict-transport-security: max-age=31536000; includeSubDomains

- `zero-downtime.log` — unbroken 200s during a rollout



- `hpa-scale.png` — replicas climbing under load
- `argocd-synced.png` — Argo CD Synced + Healthy

joseph@Joe:~/capstone-phoenix$ kubectl get application -n argocd
kubectl get application taskapp -n argocd -o wide
NAME      SYNC STATUS   HEALTH STATUS
taskapp   Synced        Healthy
NAME      SYNC STATUS   HEALTH STATUS   REVISION                  PROJECT
taskapp   Synced        Healthy         8fcbfb14f51a893892cee38f61759e9a508d9199   default
joseph@Joe:~/capstone-phoenix$ 

- `failover.png` — app up after a node drain
