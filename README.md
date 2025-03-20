# starship-job-operator
Kubernetes operator that allows you to define a plugin (container) that will run when a starship job is popped from the starship job service queue.

## CRDs

### StarshipPlugin
*What is a StarshipPlugin?*  
Your plugin is a single container.

*How does my StarshipPlugin take input?*  
Your plugin takes input by reading from the file `/var/starshipplugin/input.json` which gets mounted into your container as a volume.

*How do I know if my StarshipPlugin ran successfully?*  
Once your plugin's pod reaches the pod phase `Succeeded` or `Failed` the last 4KiB of logs are then reported to starship services' job service along with the job service job status of `SUCCESS` or `FAIL`.

*What does a StarshipPlugin CRD look like?*  
Check out below!
```yaml
apiVersion: plugins.scm.starbucks.com/v1beta1
kind: StarshipPlugin
metadata:
  name: <string>
  namespace: <string>
spec:
  starship:
    routes:
    - domain: <string>
      route: <string>
    config:
      secretRef:
        name: <string>
        namespace: <string>
      secretKey: <string>
  maxPods: <int>
  pollingInterval: <int>
  imagePullSecrets: <[]corev1.LocalObjectReference>
  container: <corev1.Container>
  volumes: <[]corev1.Volume>
```

## Install
To install the operator download the below file from the desired github release. Then apply it via kubectl.
```bash
kubectl apply -f starship-job-operator.yaml
```

## Uninstall
To uninstall the operator download the below file from the desired github release. Then delete it via kubectl.
```bash
kubectl delete -f starship-job-operator.yaml
```
