kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ec-csc
  namespace: ec-engineering
type: Opaque
data:
  ec-csc: {adminhash}
EOF
