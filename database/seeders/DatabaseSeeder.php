<?php

namespace Database\Seeders;

use App\Drivers\Registry;
use App\Models\Endpoint;
use App\Models\Provider;
use App\Models\Workflow;
use App\Models\WorkflowVersion;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Demo definitions only. No events or outbound calls are generated here.
        foreach (['inventory' => '库存演示', 'crm' => 'CRM 演示', 'sms' => '短信演示'] as $id => $name) {
            Provider::firstOrCreate(['id' => "demo.$id"], ['name' => $name, 'driver' => "demo.$id.v1",
                'base_url' => 'http://127.0.0.1:9081', 'credentials' => match ($id) {
                    'crm' => ['token' => 'local-demo-crm-token'], 'inventory' => ['key_id' => 'local-demo', 'secret' => 'local-demo-inventory-secret'], 'sms' => ['api_key' => 'local-demo-sms-key']
                },
                'settings' => ['interval_ms' => 100, 'circuit_threshold' => 5, 'circuit_seconds' => 60], 'enabled' => true]);
        }
        $apis = ['inventory.reserve' => ['inventory', 'stock.reserve'], 'crm.contact.create' => ['crm', 'contact.create'], 'crm.contact.paid' => ['crm', 'contact.mark-paid'], 'sms.order.confirm' => ['sms', 'order.confirm']];
        foreach ($apis as $id => [$provider, $operationId]) {
            $operation = app(Registry::class)->operation("demo.$provider.v1", $operationId);
            Endpoint::firstOrCreate(['id' => $id], [
                'provider_id' => "demo.$provider", 'name' => $operation['name'], 'operation' => $operationId, 'method' => $operation['method'], 'path' => $operation['path'],
                'options' => ['idempotent' => true, 'timeout' => 10], 'enabled' => true]);
        }
        $draft = ['tasks' => [
            ['key' => 'inventory.reserve', 'name' => '预留订单库存', 'depends_on' => [], 'steps' => [
                ['key' => 'reserve', 'name' => '预留库存', 'endpoint_id' => 'inventory.reserve', 'depends_on' => [], 'input' => ['order_id' => '$event.payload.order_id']]]],
            ['key' => 'crm.sync-paid', 'name' => '同步 CRM 付费状态', 'depends_on' => [], 'steps' => [
                ['key' => 'create', 'name' => '创建联系人', 'endpoint_id' => 'crm.contact.create', 'depends_on' => [], 'input' => ['contact_id' => '$event.payload.contact_id']],
                ['key' => 'mark-paid', 'name' => '更新付费状态', 'endpoint_id' => 'crm.contact.paid', 'depends_on' => ['create'], 'input' => ['contact_id' => '$steps.create.output.id', 'order_id' => '$event.payload.order_id']]]],
            ['key' => 'sms.confirm', 'name' => '发送订单确认短信', 'depends_on' => ['inventory.reserve'], 'steps' => [
                ['key' => 'send', 'name' => '发送短信', 'endpoint_id' => 'sms.order.confirm', 'depends_on' => [], 'input' => ['order_id' => '$event.payload.order_id']]]],
        ]];
        $workflow = Workflow::firstOrCreate(['id' => 'order.paid'], ['event_type' => 'order.paid.v1', 'name' => '订单支付成功', 'draft' => $draft, 'enabled' => true]);
        if (! $workflow->active_version_id) {
            $definition = $draft;
            foreach ($definition['tasks'] as &$task) {
                foreach ($task['steps'] as &$step) {
                    $api = Endpoint::with('provider')->findOrFail($step['endpoint_id']);
                    $step['endpoint_snapshot'] = ['id' => $api->id, 'name' => $api->name, 'provider_id' => $api->provider_id, 'driver' => $api->provider->driver,
                        'base_url' => $api->provider->base_url, 'operation' => $api->operation, 'method' => $api->method, 'path' => $api->path, 'options' => $api->options];
                }
            }
            unset($task,$step);
            $version = WorkflowVersion::create(['workflow_id' => $workflow->id, 'number' => 1, 'definition' => $definition]);
            $workflow->update(['active_version_id' => $version->id]);
        }
    }
}
