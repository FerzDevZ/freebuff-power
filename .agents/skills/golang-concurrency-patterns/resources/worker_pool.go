package main
import (
	"context"
	"golang.org/x/sync/errgroup"
)
func RunPool(ctx context.Context, tasks []func() error) error {
	g, ctx := errgroup.WithContext(ctx)
	for _, task := range tasks {
		t := task
		g.Go(func() error { return t() })
	}
	return g.Wait()
}
