export function getDatabaseConnection(isWriteOperation: boolean) {
  return isWriteOperation ? primaryPool : readReplicaPool;
}
