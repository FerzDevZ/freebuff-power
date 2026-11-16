-- Partial Unique Index for Soft-Deleted Tables
CREATE UNIQUE INDEX idx_users_active_email 
ON users (email) 
WHERE deleted_at IS NULL;
