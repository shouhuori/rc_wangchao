<?php

namespace App\Http\Controllers;

use App\Dispatch\Audit;
use App\Models\EventSource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SourceController extends Controller
{
    public function index()
    {
        return view('config.sources', ['sources' => EventSource::withCount('events')->orderBy('id')->get()]);
    }

    public function form(?string $id = null)
    {
        return view('config.source-form', ['source' => $id !== null ? EventSource::findOrFail($id) : new EventSource]);
    }

    public function create(Request $request)
    {
        $data = $request->validate([
            'id' => 'required|string|regex:/^[a-z0-9][a-z0-9._-]{0,99}$/|unique:event_sources,id',
            'name' => 'required|string|max:150', 'enabled' => 'sometimes|boolean',
        ]);
        [$source, $token] = DB::transaction(function () use ($request, $data) {
            $source = EventSource::create(['id' => $data['id'], 'name' => $data['name'], 'enabled' => $request->boolean('enabled')]);
            $token = $source->issueToken();
            Audit::record($request->user()->email, 'source.create', $source->id);

            return [$source, $token];
        });

        return response()->view('config.source-token', compact('source', 'token'), 201)
            ->header('Cache-Control', 'no-store, private')->header('Pragma', 'no-cache');
    }

    public function update(Request $request, string $id)
    {
        $data = $request->validate(['name' => 'required|string|max:150', 'enabled' => 'sometimes|boolean']);
        DB::transaction(function () use ($request, $id, $data) {
            $source = EventSource::lockForUpdate()->findOrFail($id);
            $source->update(['name' => $data['name'], 'enabled' => $request->boolean('enabled')]);
            Audit::record($request->user()->email, 'source.update', $id, ['enabled' => $source->enabled]);
        });

        return redirect('/sources')->with('success', '业务来源已保存。');
    }

    public function rotate(Request $request, string $id)
    {
        [$source, $token] = DB::transaction(function () use ($request, $id) {
            $source = EventSource::lockForUpdate()->findOrFail($id);
            $token = $source->issueToken();
            Audit::record($request->user()->email, 'source.rotate', $id);

            return [$source, $token];
        });

        return response()->view('config.source-token', compact('source', 'token'))
            ->header('Cache-Control', 'no-store, private')->header('Pragma', 'no-cache');
    }
}
