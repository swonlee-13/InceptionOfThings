## Starting
```
	vagrant up
```

## Destroy
```
	vagrant destroy -f
```

## Testing
```
	vargant status
	vagrant ssh <hostname>
```

## Server
```
	kubectl get nodes -o wide
	sudo service k3s status
	ifconfig eth1
	ping <workerIp>
```


## Worker
```
	sudo service k3s-agent status
	ifconfig eth1
	ping <serverIp>
```

